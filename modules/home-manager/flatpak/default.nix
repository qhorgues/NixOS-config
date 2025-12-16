{ pkgs, lib, config, ... }:
{
  home.packages = with pkgs; [
    flatpak
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:$XDG_DATA_DIRS";
  };

  home.activation.flatpak = lib.hm.dag.entryAfter ["writeBoundary"]
  ''
    ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    ${pkgs.flatpak}/bin/flatpak update --user -y
  '';
}
