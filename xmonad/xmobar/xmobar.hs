Config { font = "xft:iosevka:size=10:bold"
       , additionalFonts =
          [ "xft:FontAwesome 6 Free Solid:pixelsize=14"
          , "xft:FontAwesome:pixelsize=6:bold"
          , "xft:FontAwesome 6 Free Solid:pixelsize=13"
          , "xft:Hack Nerd Font Mono:pixelsize=15"
          , "xft:Hack Nerd Font Mono:pixelsize=25"
          ]
       , border = NoBorder
       , bgColor = "#2B2E37"
       , fgColor = "#929AAD"
       , alpha = 255
       , position = TopSize L 100 20
       , lowerOnStart = True
       , allDesktops = True
       , persistent = False
       , hideOnStart = False
       , iconRoot = "/home/shaggy/.config/xmonad/xmobar/icons/"
       , commands =
         [ Run UnsafeXPropertyLog "_XMONAD_LOG_0"
         , Run Date "%a, %d %b   <fn=1></fn>   %H:%M:%S" "date" 10
         , Run Memory ["-t","Mem: <fc=#AAC0F0><usedratio></fc>%"] 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/cpu_temp.sh" [] "cpu" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/gpu_temp.sh" [] "gpu" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/available_updates.sh" [] "updates" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/volume.sh" [] "volume" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/bluetooth.sh" [] "bluetooth" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/wifi.sh" [] "network" 10
         , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/trayer-padding.sh" [] "trayerpad" 10
         ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "\
            \    \
            \%_XMONAD_LOG_0%\
            \}\
            \<action=xdotool key super+r>%date%</action>\
            \{\
            \<action=xdotool key super+y>\
            \%volume%\
            \ \
            \%network%\
            \ \
            \|\
            \ \
            \%memory%\
            \ \
            \|\
            \ \
            \%cpu%\
            \ \
            \|\
            \ \
            \%gpu%\
            \ \
            \|\
            \</action>\
            \%trayerpad%"
       }
