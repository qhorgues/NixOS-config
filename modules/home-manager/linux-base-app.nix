{ pkgs, ... }:
{
  home.packages = with pkgs; [
    htop
    lm_sensors
    fastfetch
  ];
}
