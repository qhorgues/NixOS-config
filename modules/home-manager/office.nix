{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texliveFull
    texstudio
    onlyoffice-bin
    libreoffice
    thunderbird-latest-bin
  ];
}
