{ config, osConfig, pkgs, lib, ... }:
{
  imports = [
    ./core
    ./flatpak
    ./cryptomator
    ./discord
    ./element
    ./audio-enhancer
    ./gnome
    ./firefox
    ./thunderbird
    ./office
    ./dev
    ./graphism
    ./kdrive
    ./xdg-mime
    ./zed-editor
    ./video-downloader
    ./vm-manager
    ./vim
    ./vscode
    ./linux-base-tools
    ./ssh
    ./winboat
  ];

  home.file = lib.mkIf (!osConfig.mx.mode.server.enable) {
    ".local/share/icons/hicolor/256x256/apps/steam_icon_1903340.png".source = ./icons/steam_icon_1903340.png;
  };

  home.activation = lib.mkIf (!osConfig.mx.mode.server.enable) {
    updateIconCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "${config.home.homeDirectory}/.local/share/icons/hicolor"
    '';
  };

  home.stateVersion = osConfig.system.nixos.release;
}
