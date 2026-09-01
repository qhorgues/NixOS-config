{ pkgs, config, lib, ... }:

let
  cfg = config.mx.services.flatpak;
  flatpakApp = import ./app.nix { inherit lib; enableApp = cfg.enable; };

  flatpakSync = pkgs.writeShellApplication {
    name = "flatpak-sync";
    runtimeInputs = [ pkgs.flatpak ];
    text = ''
      wanted=(${lib.escapeShellArgs cfg.apps})
      removed=(${lib.escapeShellArgs cfg.removedApps})

      for app in ''${removed[@]+"''${removed[@]}"}; do
        if flatpak info --user "$app" >/dev/null 2>&1; then
          flatpak uninstall --user -y --noninteractive "$app"
        fi
      done

      if [ ''${#wanted[@]} -eq 0 ]; then
        exit 0
      fi

      flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

      for app in "''${wanted[@]}"; do
        if ! flatpak info --user "$app" >/dev/null 2>&1; then
          flatpak install --user -y --noninteractive flathub "$app"
        fi
      done

      flatpak update --user -y --noninteractive
    '';
  };
in
{
  options.mx.services.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak service";

    apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "com.github.tchx84.Flatseal" ];
      description = "Flatpak application IDs to install from Flathub in the user installation.";
    };

    removedApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "com.discordapp.Discord" ];
      description = ''
        Flatpak application IDs to remove from the user installation. Only
        applications listed here are uninstalled, so manually installed
        flatpaks are left untouched.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        flatpak
      ];

      home.sessionVariables = {
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:${config.home.homeDirectory}/.local/share/flatpak/exports/share:/usr/share:/var/lib/flatpak/exports/share";
      };

      systemd.user.services.flatpak-sync = {
        Unit = {
          Description = "Flatpak synchronization";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${flatpakSync}/bin/flatpak-sync";
          Restart = "on-failure";
          RestartSec = 60;
        };
      };

      systemd.user.timers.flatpak-sync = {
        Unit = {
          Description = "Regular flatpak synchronization";
        };

        Timer = {
          OnStartupSec = "2min";
          OnUnitInactiveSec = "1d";
          Unit = "flatpak-sync.service";
        };

        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      # No network access during activation: the switch only asks the user
      # manager to run the synchronization in the background.
      home.activation.flatpakSync = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user start --no-block flatpak-sync.service || true
      '';
    })

    (flatpakApp "com.github.tchx84.Flatseal")
  ];
}
