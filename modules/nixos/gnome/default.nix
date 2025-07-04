{ pkgs, lib, ... }:

{
  imports = [
    ./numlock.nix
    ./trash.nix
  ];

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

  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [{
      settings = {
        "org/gnome/settings-daemon/plugins/color" = {
            night-light-enabled = true;
        };
        "org/gnome/desktop/interface" = {
            scaling-factor = lib.gvariant.mkUint32 1;
            show-battery-percentage = true;
            text-scaling-factor = 1.;
        };
        "org/gnome/desktop/input-sources" = {
          sources = [
            (lib.gvariant.mkTuple["xkb" "fr+oss"])
          ];
        };
      };

    }];
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
  ];
}
