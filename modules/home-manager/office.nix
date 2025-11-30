{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texliveFull
    texstudio
    onlyoffice-desktopeditors
    libreoffice
    thunderbird-latest-bin
  ];
}
