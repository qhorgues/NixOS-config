{ config, lib, ... }:

let
  cfg = config.winter.programs.audio-enhancer;
in
{
  options.winter.programs.audio-enhancer = {
    enable = lib.mkEnableOption "Enable audio enhacer";
  };

  config = lib.mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
      extraPresets = {
        # Input
        input-denoizer = import ./input-denoizer.nix;

        # Output
        perfect-equalizer = import ./perfect-equalizer.nix;
        bass-boosted = import ./bass-boosted.nix;
        bass-boosted-perfect-equalizer = import ./bass-boosted-perfect-equalizer.nix;
        advanced-auto-gain = import ./advanced-auto-gain.nix;
        boosted = import ./boosted.nix;
        loundness-autogain = import ./loundness-autogain.nix;
      };
    };
  };
}
