{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.custom.pipewire;
in
{
  # Declare what settings a user of this "hello.nix" module CAN SET.
  options.custom.pipewire = {
    enable = mkEnableOption "Enable pipewire and necessary programs";
  };

  config = mkIf cfg.enable
    {
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
    };
}

