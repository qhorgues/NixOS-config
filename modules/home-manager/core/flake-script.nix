{ lib, config, pkgs, osConfig, ... }:

let
    cfg = config.winter.update;
    cfga = config.winter.auto-update;
    nix-latest-update = import ../../../pkgs/nix-latest-update.nix {
        pkgs = pkgs;
    };

    nix-update = import ../../../pkgs/nix-update.nix {
        pkgs = pkgs;
        nix-latest-update = nix-latest-update;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
    };

    nix-clean-boot = import ../../../pkgs/nix-clean-boot.nix {
        pkgs = pkgs;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
    };

    nix-clean = import ../../../pkgs/nix-clean.nix {
        pkgs = pkgs;
    };

    clean-dir = import ../../../pkgs/clean-dir.nix {
      pkgs = pkgs;
    };

    conf_service = osConfig.winter.services;

    mx-game = import ../../../pkgs/mx-game.nix {
      lib = lib;
      pkgs = pkgs;
      dockerEnable = conf_service.docker.enable;
      ollamaEnable = conf_service.llm.enable;
      open-webuiEnable = conf_service.llm.enable-open-webui;
      lampEnable = conf_service.lamp.enable;
      postgresEnable = conf_service.postgresql.enable;
      printingEnable = conf_service.printing.enable;
      teamviewerEnable = osConfig.winter.programs.team-viewer.enable;
      vmEnable = conf_service.vm.enable;
    };

in
{
    options.winter = {
        update = {
            flake_path = lib.mkOption {
                type = lib.types.str;
                default = "/etc/nixos/flake.nix";
                description = "Flake config path";
            };

            flake_config = lib.mkOption {
                type = lib.types.str;
                default = "default";
                description = "Flake config name";
            };
        };
        auto-update.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable auto update";
        };
    };

    config = lib.mkMerge [
        {
            home.packages = [
                nix-update
                nix-clean-boot
                nix-clean
                nix-latest-update
                clean-dir
                mx-game
            ];
        }
        # (lib.mkIf cfga.enable {
        #     systemd.user.services.winter-auto-update = {
        #         Unit = {
        #           Description = "Auto update services";
        #           After = [ "graphical-session.target" ];
        #         };
        #         Service = {
        #             Type = "exec";
        #             ExecStart = "${nix-update}/bin/nix-update";
        #         };
        #         Install = {
        #           WantedBy = [ "multi-user.target" ];
        #         };
        #     };

        #     systemd.user.timers.winter-auto-update = {
        #         Install = {
        #             WantedBy = [ "timers.target" ];
        #         };
        #         Unit = {
        #             Description = "Execute every day";
        #             Wants = [ "winter-auto-update-service.service" ];
        #         };
        #         Timer = {
        #             OnCalendar = "daily";
        #             Persistent = true;
        #             Unit = "winter-auto-update.service";
        #         };
        #     };
        # })
    ];
}
