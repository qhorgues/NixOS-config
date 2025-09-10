{ pkgs, lib, ... }:

{
  boot = {
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.systemd-boot.configurationLimit = lib.mkDefault 10;
    loader.efi.canTouchEfiVariables = lib.mkDefault true;
    tmp.useTmpfs = lib.mkDefault true;
    consoleLogLevel = 0;

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = lib.mkDefault [ "quiet" "udev.log_level=0" ];

    initrd.systemd.enable = lib.mkDefault true;
    plymouth.enable = lib.mkDefault true;
  };
}
