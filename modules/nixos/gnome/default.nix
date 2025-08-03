{ pkgs, lib, config, ... }:

{
    imports = [
        ./numlock.nix
        ./trash.nix
    ];

    options.winter.gnome.scaling = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "Facteur de mise à l’échelle GNOME.";
    };

    options.winter.gnome.text-scaling = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Facteur de mise à l’échelle du texte GNOME.";
    };


    config = lib.mkMerge [
        {
            services = {
                xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                excludePackages = with pkgs; [
                    xterm
                ];
                desktopManager.gnome.enable = true;
                xkb = {
                    layout = lib.mkDefault "fr";
                    variant = "";
                };
                };
            };
        }
        {
            programs.dconf = {
                enable = true;
                profiles = {
                    gdm.databases = [{
                        settings = {
                            "org/gnome/settings-daemon/plugins/color" = {
                                night-light-enabled = true;
                            };
                            "org/gnome/desktop/interface" = {
                                scaling-factor = lib.gvariant.mkUint32 config.winter.gnome.scaling;
                                show-battery-percentage = true;
                                text-scaling-factor = config.winter.gnome.text-scaling;
                            };
                            "org/gnome/desktop/input-sources" = {
                                sources = [
                                    (lib.gvariant.mkTuple["xkb" "fr+oss"])
                                ];
                            };
                        };
                    }];
                    users.databases = [{
                        settings = {
                            "org/gnome/desktop/interface" = {
                                scaling-factor = lib.gvariant.mkUint32 config.winter.gnome.scaling;
                                text-scaling-factor = config.winter.gnome.text-scaling;
                            };
                        };
                    }];
                };
            };
        }
        {
            environment.gnome.excludePackages = with pkgs; [
                atomix # puzzle game
                cheese # webcam tool
                baobab
                snapshot
                simple-scan
                eog
                file-roller
                seahorse
                epiphany # web browser
                evince # document viewer
                geary # email reader
                gnome-characters
                gnome-music
                gnome-photos
                gnome-tour
                hitori # sudoku game
                iagno # go game
                tali # poker game
                totem # video player
                yelp
                gnome-calculator
                gnome-calendar
                gnome-clocks
                gnome-contacts
                gnome-font-viewer
                gnome-logs
                gnome-maps
                gnome-screenshot
                gnome-system-monitor
                gnome-weather
                gnome-connections
                gnome-software
                gnome-disk-utility
                gnome-console
                gnome-text-editor
                nautilus
                decibels
                loupe
                cups
                simple-scan
                gnome-shell-extensions
            ];
        }
        {
            # Is used to fix blank screen on GDM

            systemd.services."getty@tty1".enable = false;
            systemd.services."autovt@tty1".enable = false;
        }
  ];
}
