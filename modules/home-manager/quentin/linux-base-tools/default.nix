{ config, pkgs, lib, ... }:
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
    ];
  };
}
