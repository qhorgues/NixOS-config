{ pkgs, ... }:
{
  home.packages = with pkgs; [
    blender
    bambu-studio
  ];
}
