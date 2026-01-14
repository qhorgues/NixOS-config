{ pkgs, config, lib, ... }:

let
  cfg = config.winter.services.ios-connect;
in
{
  options.winter.services.ios-connect = {
    enable = lib.mkEnableOption "Enbale ios connection tools";
  };

  config = lib.mkIf cfg.enable {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      libimobiledevice
      ifuse
    ];
  };
}
