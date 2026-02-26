{ pkgs, lib, ... }:

{
  boot = {
    loader.limine = {
      enable = true;
      maxGenerations = 10;
      secureBoot.enable = true;
      extraConfig = "timeout: 1\nquiet: yes\nremember_last_entry: yes";
    };

    loader.efi.canTouchEfiVariables = lib.mkDefault true;
    tmp.useTmpfs = lib.mkDefault true;
    consoleLogLevel = 3;
    initrd.verbose = false;

    kernelPackages = lib.mkDefault pkgs.linuxPackages;
    kernelParams = lib.mkDefault [
      "quiet"
      "udev.log_level=3"
      "iommu=pt" # Fix pour certain cpu AMD
    ];

    initrd.systemd.enable = lib.mkDefault true;
    plymouth.enable = lib.mkDefault true;
  };
}
