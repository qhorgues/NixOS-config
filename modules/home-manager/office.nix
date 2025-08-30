{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texliveFull
    texstudio
    onlyoffice-bin
    libreoffice-fresh
    thunderbird-latest-bin
  ];
}
