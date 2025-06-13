{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gimp3
    inkscape
    krita
  ];
}
