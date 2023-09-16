# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, hyprland, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Add hyprland cachix 
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable musnix for DJ stuff
  # musnix.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-bd69a745-a9a8-4764-8656-02817c1238a7".device = "/dev/disk/by-uuid/bd69a745-a9a8-4764-8656-02817c1238a7";
  boot.initrd.luks.devices."luks-bd69a745-a9a8-4764-8656-02817c1238a7".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "linc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;

  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable virtual box
  virtualisation.virtualbox.host.enable = false;

  # Enable kvm
  virtualisation.libvirtd.enable = false;

  programs.dconf.enable = true;
  users.extraGroups.vboxusers.members = [ "christopher" ];

  # Hyprland
  programs.hyprland.enable = true;

  # Light support for backlight
  programs.light.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.christopher = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sQh6gLkaqd1X4G5BeQ4jp/$5NtPCBB9BFS/RhzN7QllypRTwzOcgwLX1j/PqnXiSm6";
    description = "Christopher";
    extraGroups = [ "dialout" "lock" "uucp" "dialout" "plugdev" "networkmanager" "wheel" "audio" "vboxusers" "libvirtd" "adbusers" "video" ];
    packages = with pkgs; [
      firefox
      vim
      mixxx
      minecraft
      prismlauncher
      #vscodium
      #git
      #nixfmt
      rnix-lsp
      clang-tools_15
      virt-manager
      freecad
      chromium
      mattermost-desktop
      direnv
      nixpkgs-fmt

      alacritty
      rofi
    ];
    #shell = pkgs.zsh;
  };

  fonts.fonts = with pkgs; [
    font-awesome

    (nerdfonts.override { fonts = [ "FiraCode" "Agave" "Hack" "DroidSansMono" ]; })
  ];
  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;

  home-manager.users.christopher = { ... }: {
    imports = [ hyprland.homeManagerModules.default ];
    home = {
      stateVersion = "22.05";
      packages = [ ];
    };

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions =
        with pkgs.vscode-extensions; [
          #     matklad.rust-analyzer
          #    ms-python.python
          #ms-vscode.cpptools
          #llvm-vs-code-extensions.vscode-clangd
          #ms-vscode-remote.remote-ssh # won't work with vscodium
        ];
    };
    programs.bash.enable = false;

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
          bind = $mainMod, C, killactive,
          bind = $mainMod, M, exit,
          bind = $mainMod, E, exec, dolphin
          bind = $mainMod, V, togglefloating,
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  programs.adb.enable = false;
}
