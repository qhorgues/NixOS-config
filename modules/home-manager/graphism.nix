{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gimp3
    inkscape
    krita
  ];
}
