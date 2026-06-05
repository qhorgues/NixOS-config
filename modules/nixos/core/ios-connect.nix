{ pkgs, config, lib, ... }:

let
  cfg = config.mx.services.ios-connect;
in
{
  options.mx.services.ios-connect = {
    enable = lib.mkEnableOption "Enbale ios connection tools";
  };

  config = lib.mkIf (!config.mx.mode.server && cfg.enable) {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
    ];
  };
}
