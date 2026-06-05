{ lib, config, ... }:

let
  cfg = config.mx.core.sound;
in
{
  options.mx.core.sound = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sound fonctionnality";
    };
  };

  config = lib.mkIf (!config.mx.mode.server.enable && cfg.enable) {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
