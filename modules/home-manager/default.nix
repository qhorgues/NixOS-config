{ config, pkgs, lib, ... }:
{
  home.file.".local/share/icons/hicolor/256x256/apps/steam_icon_1903340.png".source = ./icons/steam_icon_1903340.png;

  home.activation.updateIconCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "${config.home.homeDirectory}/.local/share/icons/hicolor"
    '';

  home.packages = with pkgs; [

    discord

    fastfetch
    htop
    lm_sensors
    dconf-editor
    easyeffects

    video-downloader
  ];
}
