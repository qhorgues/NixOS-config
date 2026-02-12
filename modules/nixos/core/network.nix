{ config, lib, pkgs, ... }:

let
  cfg = config.winter.core.network;
in
{
  options.winter.core.network = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable networking fonctionnality";
    };
    security-mode = lib.mkEnableOption "Enable advanced networking security settings";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        networking.networkmanager.enable = lib.mkDefault true;
        networking.firewall.enable = lib.mkForce true;
      }
      (
        lib.mkIf cfg.security-mode {
          networking.hostName = (
            if config.winter.services.apache-php-mariadb.enable then
              lib.mkForce "device"
            else lib.mkForce ""
          );
          networking.networkmanager = {
            wifi = {
              macAddress = "random";
              scanRandMacAddress = true;
            };
            ethernet = {
              macAddress = "random";
            };
          };
        }
      )
    ]
  );
}
