{ pkgs, lib, config, ... }:

let
  cfg = config.mx.desktop.gnome;
  cgpu = config.mx.hardware.gpu;
  isGnome = config.mx.desktop.environment == "gnome";
  gnome-rounded-blur = pkgs.callPackage ../../../pkgs/gnome-rounded-blur.nix { };
in
{
    options.mx.desktop.gnome = {
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
      gsconnect = lib.mkEnableOption "Enable GSConnect";
      remote-desktop = lib.mkEnableOption "Enable GNOME remote desktop";
      rounded-blur = lib.mkEnableOption "gnome-rounded-blur";
    };

    imports = [
      ./numlock.nix
      ./trash.nix
      ../core/options/desktop.nix
    ];

    config = lib.mkMerge [
      (
        lib.mkIf isGnome {
          services = {
            xserver = {
              enable = true;
              videoDrivers =  [
                (
                  if cgpu.vendor == "amd"
                  then "amdgpu"
                  else if cgpu.vendor == "nvidia" then
                  cgpu.vendor
                  else "modesetting"
                )
              ];
              excludePackages = with pkgs; [
                  xterm
              ];
              xkb = {
                  layout = lib.mkDefault "fr";
                  variant = "";
              };
            };
            displayManager.gdm.enable = true;
            displayManager.defaultSession = lib.mkDefault "gnome";
            desktopManager.gnome = {
              enable = true;
              sessionPath = lib.optional cfg.rounded-blur gnome-rounded-blur;
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
                              scaling-factor = lib.gvariant.mkUint32 config.mx.desktop.gnome.scaling;
                              show-battery-percentage = true;
                              text-scaling-factor = lib.gvariant.mkDouble config.mx.desktop.gnome.text-scaling;
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
                          #     scaling-factor = lib.gvariant.mkUint32 config.mx.desktop.gnome.scaling;
                          #     text-scaling-factor = lib.gvariant.mkDouble config.mx.desktop.gnome.text-scaling;
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



        systemd.services."getty@tty1".enable = false;
        systemd.services."autovt@tty1".enable = false;
      }
    )
    (
      lib.mkIf (isGnome && cfg.gsconnect) {
        networking.firewall = rec {
          allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
          allowedUDPPortRanges = allowedTCPPortRanges;
        };
      }
    )
    (
      lib.mkIf (isGnome && cfg.remote-desktop) {
        services.gnome.gnome-remote-desktop.enable = true;
        systemd.services.gnome-remote-desktop = {
          wantedBy = [ "graphical.target" ];
        };
        networking.firewall.allowedTCPPorts = [ 3389 ];
        networking.firewall.allowedUDPPorts = [ 3389 ];
      }
    )
  ];
}
