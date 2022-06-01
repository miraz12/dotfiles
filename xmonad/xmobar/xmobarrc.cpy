Config { overrideRedirect = False
       , font     = "xft:iosevka-9"
       , bgColor  = "#5f5f5f"
       , fgColor  = "#f8f8f2"
       , position = TopSize L 100 40
       , commands = [ Run Weather "ESSA"
                        [ "--template", "<weather> <tempC>°C"
                        , "-L", "0"
                        , "-H", "25"
                        , "--low"   , "lightblue"
                        , "--normal", "#f8f8f2"
                        , "--high"  , "red"
                        ] 36000
                    , Run Alsa "default" "Master"
                        [ "--template", "<volumestatus>"
                        , "--suffix"  , "True"
                        , "--"
                        , "--on", ""
                        ]
                    , Run Memory ["--template", "Mem: <usedratio>%"] 10
                    , Run Swap [] 10
                    , Run Date "%a %Y-%m-%d <fc=#8be9fd>%H:%M</fc>" "date" 10
                    , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/gpu_temp.sh" [] "gpu" 10
                    , Run Com "/home/shaggy/.config/xmonad/xmobar/scripts/cpu_temp.sh" [] "cpu" 10
                    , Run Com "/home/shaggy/.config/xmonad/xmobar/padding-icon.sh" ["panel"] "trayerpad" 20
                    , Run XMonadLog
                    ]
       , sepChar  = "%"
       , alignSep = "}{"
       , template = "%XMonadLog% }{ %alsa:default:Master% | %cpu% | %gpu% | %memory% * %swap% | %ESSA% | %date% | %trayerpad%"
       }
