{ pkgs, winter, ... }:
{
  home.packages = with pkgs; [
    (import ../../pkgs/blender {
      acceleration = config.winter.hardware.acceleration;})
    bambu-studio
  ];
}
