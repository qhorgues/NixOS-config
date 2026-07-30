{ config, lib, ... }:

{
  options = {
    mx.desktop.gnome.numlock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "disable NumLock auto";
    };
    };

  config = lib.mkIf (config.mx.desktop.environment == "gnome" && config.mx.desktop.gnome.numlock) {
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
