{ config, pkgs, lib, osConfig, ... }:
let
  cfg = config.mx.programs.linux-base-tools;
  gpu = osConfig.mx.hardware.gpu;
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
    ] ++ lib.optional (gpu.vendor != null) (
      if gpu.vendor == "amd" then
        nvtopPackages.amd
      else if gpu.vendor == "nvidia" then
        nvtopPackages.nvidia
      else if gpu.vendor == "intel" then
        nvtopPackages.intel
      else
        nvtopPackages.full);
  };
}
