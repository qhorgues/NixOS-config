{ config, lib, ... }:

{
  options = {
    enableNumlockConfig = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "disable NumLock auto";
    };
    };

  config = lib.mkIf config.enableNumlockConfig {
    programs.dconf = {
        enable = true;
        profiles.gdm.databases = [{
        settings = {
            "org/gnome/desktop/peripherals/keyboard" = {
            numlock-state = true;
            };
        };
        }];
        profiles.users.databases = [{
        settings = {
            "org/gnome/desktop/peripherals/keyboard" = {
            numlock-state = true;
            };
        };
        }];
    };
  };
}
