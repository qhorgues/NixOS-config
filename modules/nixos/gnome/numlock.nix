{ config, lib, ... }:

{
  options = {
    winter.gnome.numlock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "disable NumLock auto";
    };
    };

  config = lib.mkIf config.winter.gnome.numlock {
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
