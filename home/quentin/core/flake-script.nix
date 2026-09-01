{ lib, config, pkgs, modulixos-config, ... }:

let
    cfg = config.mx.update;
    cfga = config.mx.auto-update;
    inherit (modulixos-config.packages.${pkgs.stdenv.hostPlatform.system})
      mx-latest-update mx-clean clean-dir;

    mx-update = modulixos-config.lib.mkMxUpdate {
        inherit pkgs;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
    };

    mx-clean-boot = modulixos-config.lib.mkMxCleanBoot {
        inherit pkgs;
        flake_path = cfg.flake_path;
        flake_config = cfg.flake_config;
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
                mx-update
                mx-clean-boot
                mx-clean
                mx-latest-update
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
        #             ExecStart = "${mx-update}/bin/mx-update";
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
