{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.audio-enhancer;
in
{
  options.winter.programs.audio-enhancer = {
    enable = lib.mkEnableOption "Enable audio enhacer";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.easyeffects = {
      Unit = {
        After = [ "graphical-session.target" "pipewire.service" ];
        Requires = [ "graphical-session.target" ];
      };
      Service = {
        # Importer les variables d'environnement de la session graphique
        ImportEnvironment = [ "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" ];
        Environment = [
          "QT_QPA_PLATFORM=wayland;xcb"  # Essaie wayland puis xcb
        ];
      };
      Install = {
        WantedBy = lib.mkForce [ "graphical-session.target" ];
      };
    };
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
