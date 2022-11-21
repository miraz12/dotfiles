{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-deprecations #-}
import XMonad
import System.Exit
import Prelude hiding (log)
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import Data.Maybe (fromJust)
import Data.Semigroup
import Data.Bits (testBit)
import Control.Monad (unless, when)
import Foreign.C (CInt)
import Data.Foldable (find)

import XMonad.Hooks.DynamicProperty
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.InsertPosition (insertPosition, Focus(Newer), Position (Master, End))
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.StatusBar
import XMonad.Hooks.ManageHelpers (isDialog, doCenterFloat, doSink)
import XMonad.Hooks.RefocusLast (isFloat)

import XMonad.Layout.Spacing (Spacing, spacingRaw, Border (Border))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Named (named)
import XMonad.Layout.Decoration (ModifiedLayout)
import XMonad.Layout.DraggingVisualizer (draggingVisualizer)
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NBFULL))
import XMonad.Layout.MultiToggle (EOT (EOT), Toggle (Toggle), mkToggle, (??))
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.IndependentScreens
import XMonad.Layout.HintedGrid
import XMonad.Layout.PerWorkspace

import XMonad.Util.NamedScratchpad
import XMonad.Util.Loggers (logLayoutOnScreen, logTitleOnScreen, shortenL, wrapL, xmobarColorL)
import XMonad.Util.EZConfig (additionalKeysP)
import qualified XMonad.Util.ExtensibleState as XS

import XMonad.Actions.CycleWS
import XMonad.Actions.TiledWindowDragging
import qualified XMonad.Actions.FlexibleResize as Flex
import XMonad.Actions.UpdatePointer (updatePointer)
import XMonad.Actions.OnScreen (onlyOnScreen)
import XMonad.Actions.Warp (warpToScreen)
import Data.List
import qualified Data.List as L


grey1, grey2, grey3, grey4, cyan, orange :: String
grey1  = "#2B2E37"
grey2  = "#555E70"
grey3  = "#697180"
grey4  = "#8691A8"
cyan   = "#8BABF0"
orange = "#C45500"

myWorkspaces :: [[Char]]
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]

actionPrefix, actionButton, actionSuffix :: [Char]
actionPrefix = "<action=`xdotool key super+"
actionButton = "` button="
actionSuffix = "</action>"

addActions :: [(String, Int)] -> String -> String
addActions [] ws = ws
addActions (x:xs) ws = addActions xs (actionPrefix ++ k ++ actionButton ++ show b ++ ">" ++ ws ++ actionSuffix)
    where k = fst x
          b = snd x


currentScreen :: X ScreenId
currentScreen = gets (W.screen . W.current . windowset)

isOnScreen :: ScreenId -> WindowSpace -> Bool
isOnScreen s ws = s == unmarshallS (W.tag ws)

workspaceOnCurrentScreen :: WSType
workspaceOnCurrentScreen = WSIs $ do
  s <- currentScreen
  return $ \x -> W.tag x /= "NSP" && isOnScreen s x


------------------------------------------------------------------------
--

switchScreen :: Int -> X ()
switchScreen d = do s <- screenBy d
                    mws <- screenWorkspace s
                    warpToScreen s 0.618 0.618
                    case mws of
                         Nothing -> return ()
                         Just ws -> windows (W.view ws)


------------------------------------------------------------------------
--

mySpacing :: Integer -> Integer -> l a -> ModifiedLayout Spacing l a
mySpacing i j = spacingRaw False (Border i i i i) True (Border j j j j) True

myLayoutHook = avoidStruts $ onWorkspaces ["0_9", "1_9"] layoutGrid $ layoutTall ||| layoutTabbed
  where
    layoutTall = mkToggle (NBFULL ?? EOT) . named "tall" $ draggingVisualizer $ smartBorders $ mySpacing 15 15 $ mouseResizableTile { masterFrac = 0.65, draggerType = FixedDragger 0 30}
    layoutGrid = mkToggle (NBFULL ?? EOT) . named "grid" $ draggingVisualizer $ smartBorders $ mySpacing 15 15 $ Grid False
    layoutTabbed = mkToggle (NBFULL ?? EOT) . named "full" $ smartBorders $ mySpacing 5 5 $ tabbed shrinkText myTabTheme
    myTabTheme = def
      { fontName            = "xft:iosevka:size=12:bold"
      , activeColor         = grey1
      , inactiveColor       = grey1
      , activeBorderColor   = grey1
      , inactiveBorderColor = grey1
      , activeTextColor     = cyan
      , inactiveTextColor   = grey3
      , decoHeight          = 25
      }


------------------------------------------------------------------------
--

(~?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~? x = fmap (x `L.isInfixOf`) q

(/=?) :: Eq a => Query a -> a -> Query Bool
q /=? x = fmap (/= x) q

myManageHook :: ManageHook
myManageHook = composeAll
  [ resource  =? "desktop_window" --> doIgnore
  , isFloat --> doCenterFloat
  , isDialog --> doCenterFloat
  , title =? "leagueclientux.exe" --> doFloat
  , title =? "riotclientux.exe" --> doFloat
  , insertPosition Master Newer
  ] <+> manageDocks  


------------------------------------------------------------------------
--

myStartupHook :: X ()
myStartupHook = do
    spawn "killall trayer; trayer --monitor 2 --edge top --align right --widthtype request --padding 7 --iconspacing 5 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x2B2E37  --height 20 &"
    spawn "killall feh; feh --bg-fill --no-fehbg ~/Pictures/snm.jpg &"
    spawn "killall nextcloud; nextcloud &"
    spawn "killall emacs; emacs --daemon &"
    spawn "killall signal-desktop; signal-desktop --use-tray-icon &"
    modify $ \xstate -> xstate { windowset = onlyOnScreen 1 "1_1" (windowset xstate) }


------------------------------------------------------------------------
--

myWorkspaceIndices :: M.Map [Char] Integer
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1..]

clickable :: [Char] -> [Char] -> [Char]
clickable icon ws = addActions [ (show i, 1), ("q", 2), ("Left", 4), ("Right", 5) ] icon
                    where i = fromJust $ M.lookup ws myWorkspaceIndices

myStatusBarSpawner :: Applicative f => ScreenId -> f StatusBarConfig
myStatusBarSpawner (S s) = do
                    pure $ statusBarPropTo ("_XMONAD_LOG_" ++ show s)
                          ("xmobar -x " ++ show s ++ " ~/.config/xmonad/xmobar/xmobar" ++ show s ++ ".hs")
                          (pure $ myXmobarPP (S s))


myXmobarPP :: ScreenId -> PP
myXmobarPP s  = filterOutWsPP [scratchpadWorkspaceTag] . marshallPP s $ def
  { ppSep = ""
  , ppWsSep = ""
  , ppCurrent = xmobarColor cyan "" . clickable wsIconFull
  , ppVisible = xmobarColor grey4 "" . clickable wsIconFull
  , ppVisibleNoWindows = Just (xmobarColor grey4 "" . clickable wsIconFull)
  , ppHidden = xmobarColor grey2 "" . clickable wsIconHidden
  , ppHiddenNoWindows = xmobarColor grey2 "" . clickable wsIconEmpty
  , ppUrgent = xmobarColor orange "" . clickable wsIconFull
  , ppOrder = \(ws : _ : _ : extras) -> ws : extras
  , ppExtras  = [ wrapL (actionPrefix ++ "n" ++ actionButton ++ "1>") actionSuffix
                $ wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
                $ wrapL (actionPrefix ++ "Left" ++ actionButton ++ "4>") actionSuffix
                $ wrapL (actionPrefix ++ "Right" ++ actionButton ++ "5>") actionSuffix
                $ wrapL "    " "    " $ layoutColorIsActive s (logLayoutOnScreen s)
                , wrapL (actionPrefix ++ "q" ++ actionButton ++ "2>") actionSuffix
                $  titleColorIsActive s (shortenL 81 $ logTitleOnScreen s)
                ]
  }
  where
    wsIconFull   = " <fn=2>\xf111</fn> "
    wsIconHidden = " <fn=2>\xf111</fn> "
    wsIconEmpty  = " <fn=2>\xf10c</fn> "
    titleColorIsActive n l = do
      c <- withWindowSet $ return . W.screen . W.current
      if n == c then xmobarColorL cyan "" l else xmobarColorL grey3 "" l
    layoutColorIsActive n l = do
      c <- withWindowSet $ return . W.screen . W.current
      if n == c then wrapL "<icon=/home/shaggy/.config/xmonad/xmobar/icons/" "_selected.xpm/>" l else wrapL "<icon=/home/shaggy/.config/xmonad/xmobar/icons/" ".xpm/>" l


------------------------------------------------------------------------
--

main :: IO ()
main = xmonad
       . ewmh
       . ewmhFullscreen
       . dynamicSBs myStatusBarSpawner
       . docks
       $ def
        { focusFollowsMouse  = True
        , clickJustFocuses   = False
        , borderWidth        = 3
        , modMask            = mod4Mask
        , normalBorderColor  = grey2
        , focusedBorderColor = cyan
        , terminal           = "kitty"
        , workspaces         = withScreens 2 myWorkspaces
        , layoutHook         = myLayoutHook
        , manageHook         = myManageHook
        , startupHook        = myStartupHook

        , rootMask = rootMask def .|. pointerMotionMask
        } `additionalKeysP`
          [ ("M-f"  , spawn "firefox"                   )
           ,("M-p"  , spawn "rofi -show run"                   )
           ,("M-l", spawn "/home/shaggy/.config/xmonad/scripts/layout_switch.sh us se")
           ,("M-i"  , spawn "emacsclient --create-frame --alternate-editor=''"                   )
           ,("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1.5%")
           ,("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@  -1.5%")
           ,("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
           ,("<XF86AudioMicMute>", spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
           ,("<XF86AudioPlay>", spawn "playerctl play-pause")
           ,("<XF86AudioPrev>", spawn "playerctl previous")
           ,("<XF86AudioNext>", spawn "playerctl next")
           ,("<XF86MonBrightnessUp>", spawn "lux -a 5%")
           ,("<XF86MonBrightnessDown>", spawn "lux -s 5%")
          ]
