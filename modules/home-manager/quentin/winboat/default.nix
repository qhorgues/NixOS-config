{ config, osConfig, pkgs, lib, ... }:

let
  cfg = config.winter.programs.winboat;
in
{
  options.winter.programs.winboat = {
    enable = lib.mkEnableOption "Enable Winboat for Windows 11 containers";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (osConfig.winter.services.docker.enable && lib.elem config.home.username osConfig.winter.services.docker.users);
        message = "You must enable Docker and be an authorized docker user to install the Winboat module.";
      }
    ];
    home.packages = with pkgs; [
      winboat
    ];
  };
}
