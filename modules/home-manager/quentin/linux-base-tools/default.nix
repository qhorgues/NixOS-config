{ config, pkgs, lib, ... }:
let
  cfg = config.winter.programs.linux-base-tools;
in
{
  options.winter.programs.linux-base-tools = {
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
