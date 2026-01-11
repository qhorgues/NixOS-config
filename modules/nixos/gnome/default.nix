{ pkgs, lib, config, ... }:

let
  cfg = config.winter.gnome;
in
{
    options.winter.gnome = {
      enable = lib.mkEnableOption "Enable GNOME desktop environment";

      scaling = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "GNOME scaling for GDM";
      };
      text-scaling = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "GNOME text scaling for GDM";
      };
    };

    imports = [
      ./numlock.nix
      ./trash.nix
    ];

    config = lib.mkIf cfg.enable {
      services = {
        xserver = {
          enable = true;
          videoDriver = config.winter.hardware.gpu.vendor;
          excludePackages = with pkgs; [
              xterm
          ];
          xkb = {
              layout = lib.mkDefault "fr";
              variant = "";
          };
        };
        displayManager.gdm.enable = true;
        desktopManager.gnome = {
          enable = true;
          extraGSettingsOverrides = ''
            [org.gnome.mutter]
            experimental-features=['variable-refresh-rate','scale-monitor-framebuffer','xwayland-native-scaling']
          ''; #'scale-monitor-framebuffer','xwayland-native-scaling'
        };
      };

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
                          text-scaling-factor = lib.gvariant.mkDouble config.winter.gnome.text-scaling;
                      };
                      "org/gnome/desktop/input-sources" = {
                          sources = [
                              (lib.gvariant.mkTuple["xkb" "fr+oss"])
                          ];
                      };
                  };
              }];
              user.databases = [{
                  settings = {
                      "org/gnome/settings-daemon/plugins/color" = {
                          night-light-enabled = true;
                      };
                      # "org/gnome/desktop/interface" = {
                      #     scaling-factor = lib.gvariant.mkUint32 config.winter.gnome.scaling;
                      #     text-scaling-factor = lib.gvariant.mkDouble config.winter.gnome.text-scaling;
                      # };
                  };
              }];
          };
      };
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
          showtime
          decibels
      ];

    networking.firewall = rec {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };

    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
