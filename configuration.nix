# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/hyprland.nix
      ./modules/pipewire.nix
    ];
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # Enable hyprland setup
  custom.hyprland.enable = true;

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

  # Enable pipewire setup
  custom.pipewire.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable virtual box
  virtualisation.virtualbox.host.enable = false;

  # Enable kvm
  virtualisation.libvirtd.enable = false;

  programs.dconf.enable = true;
  users.extraGroups.vboxusers.members = [ "christopher" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.christopher = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sQh6gLkaqd1X4G5BeQ4jp/$5NtPCBB9BFS/RhzN7QllypRTwzOcgwLX1j/PqnXiSm6";
    description = "Christopher";
    extraGroups = [ "dialout" "lock" "uucp" "dialout" "plugdev" "networkmanager" "wheel" "audio" "vboxusers" "libvirtd" "adbusers" ];
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
    ];
    #shell = pkgs.zsh;
  };

  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.ausweisapp.enable = true;
  programs.ausweisapp.openFirewall = true;

  home-manager.users.christopher = { ... }: {
    imports = [ ];
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
