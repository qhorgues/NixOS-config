{ pkgs, config, lib, ... }:

let
  cfg = config.mx.services.flatpak;
  flatpakApp = import ../flatpak/app.nix {
    inherit pkgs lib;
    enableApp = cfg.enable;
  };
in
{
  options.mx.services.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak service";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      flatpak
    ];

    home.sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:${config.home.homeDirectory}/.local/share/flatpak/exports/share:/usr/share:/var/lib/flatpak/exports/share";
    };

    home.activation.flatpak = lib.hm.dag.entryAfter ["writeBoundary"]
    ''
      ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';

    systemd.user.services.flatpak-update = {
      Unit = {
        Description = "Flatpak updater";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.flatpak}/bin/flatpak update --user -y";
        Restart = "on-failure";
        RestartSec = 60;
      };
    };

    systemd.user.timers.flatpak-update = {
      Unit = {
        Description = "Auto flatpak update";
      };

      Timer = {
        OnActiveSec = "5min";
        Unit = "flatpak-update.service";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    home.activation.flatseal = flatpakApp "com.github.tchx84.Flatseal";
  };
}
