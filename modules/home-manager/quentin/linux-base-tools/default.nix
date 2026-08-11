{ config, pkgs, lib, osConfig, ... }:
let
  cfg = config.mx.programs.linux-base-tools;
in
{
  options.mx.programs.linux-base-tools = {
    enable = lib.mkEnableOption "Install linux base tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      htop
      lm_sensors
      fastfetch
      (if osConfig.mx.hardware.gpu == "amd" then
        nvtopPackages.amd
      else if osConfig.mx.hardware.gpu == "nvidia" then
        nvtopPackages.nvidia
      else if osConfig.mx.hardware.gpu == "intel" then
        nvtopPackages.intel
      else
        nvtopPackages.full)
    ];
  };
}
