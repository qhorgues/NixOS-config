{ lib, config, pkgs, ... }:

let
    cfg = config.mx.update;
    cfga = config.mx.auto-update;
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
in
{
    options.mx = {
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
            ];
        }
        # (lib.mkIf cfga.enable {
        #     systemd.user.services.mx-auto-update = {
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

        #     systemd.user.timers.mx-auto-update = {
        #         Install = {
        #             WantedBy = [ "timers.target" ];
        #         };
        #         Unit = {
        #             Description = "Execute every day";
        #             Wants = [ "mx-auto-update-service.service" ];
        #         };
        #         Timer = {
        #             OnCalendar = "daily";
        #             Persistent = true;
        #             Unit = "mx-auto-update.service";
        #         };
        #     };
        # })
    ];
}
