{ config, lib, ... }:

let
  cfg = config.winter.services.remote-desktop;
in
{
  options.winter.services.remote-desktop = {
    enable = lib.mkEnableOption "Enable remote desktop server";
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = true;
    };
  };
}
