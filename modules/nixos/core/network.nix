{ config, lib, ... }:

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

  config = lib.mkMerge [
      (
        lib.mkIf cfg.enable {
          networking.networkmanager.enable = lib.mkDefault true;
          networking.firewall.enable = lib.mkForce true;
        }
      )
      (
        lib.mkIf (cfg.enable && cfg.security-mode) {
          networking.hostName = lib.mkForce "";
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
  ];
}
