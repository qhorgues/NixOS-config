{ lib, config, pkgs, ... }:

let
    cfg = config.winter.update;
    cfga = config.winter.auto-update;
    flake-update = import ../../pkgs/flake-update.nix {
        pkgs = pkgs;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
    };

    nix-clean-boot = import ../../pkgs/nix-clean-boot.nix {
        pkgs = pkgs;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
    };

    nix-clean = import ../../pkgs/nix-clean.nix {
        pkgs = pkgs;
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
            environment.systemPackages = [
                flake-update
                nix-clean-boot
                nix-clean
            ];
        }
        (lib.mkIf cfga.enable {
            systemd.services.winter-auto-update = {
                description = "Auto update services";
                serviceConfig = {
                    ExecStart = "${flake-update}/bin/flake-update";
                };
                wantedBy = [ "multi-user.target" ];
            };

            systemd.timers.winter-auto-update-timer = {
                description = "Execute every day";
                wantedBy = [ "timers.target" ];
                timerConfig = {
                    OnCalendar = "daily";
                    Unit = "winter-auto-update-service.service";
                };
            };
        })
    ];
}
