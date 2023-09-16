{ lib, config, pkgs, hyprland, ... }:
with lib;
let
  # Shorter name to access final settings a 
  # user of hello.nix module HAS ACTUALLY SET.
  # cfg is a typical convention.
  cfg = config.custom.hyprland;
in
{
  # Declare what settings a user of this "hello.nix" module CAN SET.
  options.custom.hyprland = {
    enable = mkEnableOption "Enable hyprland, waybar, light";
  };

  config = mkIf cfg.enable {
    # Add hyprland cachix 
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    # Hyprland
    programs.hyprland.enable = true;

    # Light support for backlight
    programs.light.enable = true;

    users.users.christopher = {
      # Add user to group for enabling brightness setting to user 
      extraGroups = [ "video" ];
      packages = with pkgs; [
        alacritty # Terminal emulator
        rofi # Launcher
      ];
    };

    fonts.fonts = with pkgs; [
      font-awesome
      (nerdfonts.override { fonts = [ "FiraCode" "Agave" "Hack" "DroidSansMono" ]; }) # Fonts for waybar
    ];

    home-manager.users.christopher = { ... }: {
      imports = [ hyprland.homeManagerModules.default ];

      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.extraConfig =
        let
          brightnessIncreaseStep = "5";
          brightnessDecreaseStep = "5";
          audioDecreasePercent = "5";
          audioIncreasePercent = "5";

        in
        ''
          $mod = SUPER
          bind=$mod,F,fullscreen
          bind=$mod,M, exec, swaylock
          bind = , Print, exec, grimblast copy area

          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          ${builtins.concatStringsSep "\n" (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in ''
                bind = $mod, ${ws}, workspace, ${toString (x + 1)}
                bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
              ''
            )
            10)}

            autogenerated = 0 # remove this line to remove the warning
            # exec-once = waybar & hyprpaper & firefox
            # See https://wiki.hyprland.org/Configuring/Monitors/
            monitor=,highres,auto,1


            # See https://wiki.hyprland.org/Configuring/Keywords/ for more

            # Execute your favorite apps at launch
            # exec-once = waybar & hyprpaper & firefox

            # Source a file (multi-file configs)
            # source = ~/.config/hypr/myColors.conf

            # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
            input {
                kb_layout = de
                kb_variant =
                kb_model =
                kb_options =
                kb_rules =

                follow_mouse = 1

                touchpad {
                    natural_scroll = yes
                }

                sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
            }

            general {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more

                gaps_in = 1
                gaps_out = 1
                border_size = 2
                col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
                col.inactive_border = rgba(595959aa)

                layout = dwindle
            }

            animations {
                enabled = no

                # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

                bezier = myBezier, 0.05, 0.9, 0.1, 1.05

                animation = windows, 1, 7, myBezier
                animation = windowsOut, 1, 7, default, popin 80%
                animation = border, 1, 10, default
                animation = fade, 1, 7, default
                animation = workspaces, 1, 6, default
            }

            dwindle {
                # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                preserve_split = yes # you probably want this
            }

            master {
                # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                new_is_master = true
            }

            gestures {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                workspace_swipe = on
            }

            # Example per-device config
            # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
            device:epic mouse V1 {
                sensitivity = -0.5
            }

            $mainMod = SUPER

            # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
            bind = $mainMod, Q, exec, alacritty
            bind = $mainMod SHIFT, Q, killactive,
            bind = $mainMod SHIFT ALT, Q, exit,
            bind = $mainMod, E, exec, dolphin
            bind = $mainMod, space, togglefloating,
            bind = $mainMod, D, exec, rofi -show run
            bind = $mainMod, P, pseudo, # dwindle
            bind = $mainMod, S, togglesplit, # dwindle

            # Move focus with mainMod + arrow keys
            bind = $mainMod,H, movefocus, l
            bind = $mainMod,L, movefocus, r
            bind = $mainMod,J, movefocus, u
            bind = $mainMod,K, movefocus, d

            # Scroll through existing workspaces with mainMod + scroll
            bind = $mainMod, mouse_down, workspace, e+1
            bind = $mainMod, mouse_up, workspace, e-1

            # Move/resize windows with mainMod + LMB/RMB and dragging
            bindm = $mainMod, mouse:272, movewindow
            bindm = $mainMod, mouse:273, resizewindow

            # Brightness control
            bind=,XF86MonBrightnessDown,exec, light -U ${brightnessDecreaseStep}
            bind=,XF86MonBrightnessUp,exec, light -A ${brightnessIncreaseStep}
        
            # Lower and raise volume with hold 
            binde=, XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${audioDecreasePercent}%-
            binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ ${audioIncreasePercent}%+

            # Mute output and mute input toggle 
            binde=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            binde=, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        
        '';

      programs.waybar = {
        enable = true;
        systemd.enable = true;
        style = ''
       
        * {
            /* `otf-font-awesome` is required to be installed for icons */
            border: #333333;
            border-radius: 10px;
            /* border-radius: 50%; */
            font-family:  "Hack Nerd Font", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
            /* background-color: #2B3031; */
            background-color: rgba(43, 48, 59, .0);
        }
        
        tooltip * {
            background-color: black;
        }

        window#waybar {
            /* border-bottom: 3px solid rgba(100, 114, 125, 0.5); */
            color: #FFFFFF;
            transition-property: background-color;
            transition-duration: .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        /*
        window#waybar.empty {
            background-color: transparent;
        }
        window#waybar.solo {
            background-color: #FFFFFF;
        }
        */

        window#waybar.termite {
            background-color: #3F3F3F;
        }

        window#waybar.firefox {
            background-color: #000000;
            border: none;
        }

        button {
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each button name */
            border: none;
            border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button {
            padding: 0 0.3em;
            background-color: transparent;
            color: #ffffff;
        }

        #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
            /* background-color: #BBCCDD; */
            border-radius: 50%;
        }

        #window,
        #workspaces {
            margin: 0 4px;
        }

        #workspaces,
        #workspaces button,
        #workspaces button:hover,
        #workspaces button.focused,
        #workspaces button.urgent {
            padding-right: 0px;
            padding: 0px 6px;
            padding-left: 2px;
        }

        #mode {
            background-color: #64727D;
            border-bottom: 3px solid #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #custom-power,
        #mpd {
            padding: 0px 9px;
            padding-right: 13px;
            margin: 3px 3px;
            color: #333333;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        #clock {
            background-color: #bbccdd;
        }

        #battery {
            background-color: #bbccdd;
            color: #333333;
        }

        #battery.charging, #battery.plugged {
            color: #ffffff;
            background-color: #26A65B;
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: #000000;
            }
        }

        #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: #ffffff;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        label:focus {
            background-color: #000000;
        }

        #cpu {
            background-color: #bbccdd;
            color: #000000;
        }

        #memory {
            background-color: #bbccdd;
        }

        #disk {
            background-color: #bbccdd;
        }

        #backlight {
            background-color: #bbccdd;
        }

        #network {
            background-color: #bbccdd;
        }

        #network.disconnected {
            background-color: #f53c3c;
        }

        #pulseaudio {
            background-color: #bbccdd;
        }

        #pulseaudio.muted {
            background-color: #bbccdd;
        }

        #wireplumber {
            background-color: #bbccdd;
        }

        #wireplumber.muted {
            background-color: #f53c3c;
        }

        #custom-media {
            background-color: #66cc99;
            color: #2a5c45;
            min-width: 100px;
        }

        #custom-media.custom-spotify {
            background-color: #66cc99;
        }

        #custom-media.custom-vlc {
            background-color: #ffa000;
        }

        #temperature {
            background-color: #bbccdd;
        }

        #temperature.critical {
            background-color: #eb4d4b;
        }

        #tray {
            background-color: #bbccdd;
        }
        #custom-power {
          background-color: #BBCCDD;
          padding-right: 13px;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            background-color: #eb4d4b;
        }

        #idle_inhibitor {
            background-color: #bbccdd;
        }

        #idle_inhibitor.activated {
            background-color: #ecf0f1;
            color: #2d3436;
        }

        #mpd {
            background-color: #bbccdd;
        }

        #mpd.disconnected {
            background-color: #f53c3c;
        }

        #mpd.stopped {
            background-color: #90b1b1;
        }

        #mpd.paused {
            background-color: #51a37a;
        }

        #language {
            background: #bbccdd;
            color: #333333;
            padding: 0 5px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state {
            background: #bbccdd;
            color: #333333;
            padding: 0 0px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state > label {
            padding: 0 5px;
        }

        #keyboard-state > label.locked {
            background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad {
            background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad.empty {
        	background-color: transparent;
        }
      '';
        settings = [{
          layer = "top";
          position = "top";
          margin-left = 10;
          margin-right = 10;
          margin-top = 5;

          modules-left = [ "custom/power" "custom/media" "clock" "cpu" ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [ "network" "backlight" "pulseaudio" "battery" "tray" ];


          "hyprland/workspaces" = {
            on-click = "activate";
            format = "{icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "urgent" = "";
              "active" = "";
              "default" = "";
            };
          };

          "hyprland/window" = {
            "format" = "{title}";
            "max-length" = 50;
            #"rewrite"={
            # "(.*) - Mozilla Firefox": "🌎 $1",
            # "(.*) - vim": " $1",
            # "(.*) - zsh": " [$1]"
            #    }
          };
          "keyboard-state" = {
            "numlock" = true;
            "capslock" = true;
            "format" = "{name} {icon}";
            "format-icons" = {
              "locked" = "";
              "unlocked" = "";
            };
          };

          "tray" = {
            # "icon-size"= 21;
            "spacing" = 10;
          };
          "clock" = {
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format-alt" = "{:%Y-%m-%d}";
          };
          "temperature" = {
            # "thermal-zone"= 2;
            # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
            "critical-threshold" = 80;
            # "format-critical"= "{temperatureC}°C {icon}";
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = [ "" "" "" ];
          };
          "cpu" = {
            "interval" = 5;
            "format" = "{usage}% ";
            "tooltip" = false;
          };
          "backlight" = {
            # "device"= "acpi_video1";
            "format" = "{percent}% {icon}";
            "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
          };
          "battery" = {
            "states" = {
              # "good"= 95;
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{capacity}% {icon}";
            "format-charging" = "{capacity}% ";
            "format-plugged" = "{capacity}% ";
            "format-alt" = "{time} {icon}";
            # "format-good"= ""; # An empty format will hide the module
            # "format-full"= "";
            "format-icons" = [ "" "" "" "" "" ];
          };
          "battery#bat2" = {
            "bat" = "BAT2";
          };
          "network" = {
            # "interface"= "wlp2*"; # (Optional) To force the use of this interface
            "format-wifi" = ""; #({essid} {signalStrength}%) 
            "format-ethernet" = "{ipaddr}/{cidr} ";
            "tooltip-format-wifi" = "{essid} ({signalStrength}%) ";
            "tooltip-format" = "{ifname} via {gwaddr} ";
            "format-linked" = "{ifname} (No IP) ";
            "format-disconnected" = "Disconnected ⚠";
            "format-alt" = "{ifname}: {ipaddr}/{cidr}";
          };
          "pulseaudio" = {
            # "scroll-step"= 1; # %; can be a float
            "format" = "{volume}% {icon}"; #{format_source}";
            "format-bluetooth" = "{volume}% {icon} 󰂯"; #{format_source}";
            "format-bluetooth-muted" = "󰖁 {icon} 󰂯"; #{format_source}";
            "format-muted" = "󰖁 {format_source}";
            "format-source" = "{volume}% ";
            "format-source-muted" = "";
            "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "󱡒";
              "headset" = "󰋎";
              "phone" = "";
              "portable" = "";
              "car" = "";
              "default" = [ "" "" "" ];
            };
            "on-click" = "pavucontrol";
          };
          "custom/media" = {
            "format" = "{icon} {}";
            "return-type" = "json";
            "max-length" = 40;
            "format-icons" = {
              "spotify" = "";
              "default" = "🎜";
            };
            "escape" = true;
            "exec" = "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
            # "exec"= "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
          };
          "custom/power" = {
            "format" = "{icon}";
            "format-icons" = ""; # 󰣇
            "exec-on-event" = "true";
            "on-click" = "~/.config/hypr/scripts/sessionMenu.sh";
          };

        }];
      };
    };
  };
}
