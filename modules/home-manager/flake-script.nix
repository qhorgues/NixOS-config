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
            home.packages = [
                flake-update
                nix-clean-boot
                nix-clean
            ];
        }
        (lib.mkIf cfga.enable {
            systemd.user.services.winter-auto-update = {
                Unit = {
                  Description = "Auto update services";
                  After = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "exec";
                    ExecStart = "${flake-update}/bin/flake-update";
                };
                Install = {
                  WantedBy = [ "multi-user.target" ];
                };
            };

            systemd.user.timers.winter-auto-update-timer = {
                Unit = {
                    Description = "Execute every day";
                    Wants = [ "winter-auto-update-service.service" ];
                    WantedBy = [ "timers.target" ];
                };
                Timer = {
                    OnCalendar = "daily";
                    Persistent = true;
                    Unit = "winter-auto-update-service.service";
                };
            };
        })
    ];
}
