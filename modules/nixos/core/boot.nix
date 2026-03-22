{ pkgs, lib, config, ... }:

let
  cfg = config.mx.bootloader;
in
{
  options.mx.bootloader = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use default bootloader";
    };
  };
  config = {
    boot = lib.mkMerge [
      (
        lib.mkIf cfg.enable {
          loader.limine = {
            enable = true;
            maxGenerations = 10;
            secureBoot.enable = true;
            extraConfig = "timeout: 1\nquiet: yes\nremember_last_entry: yes";
          };

          loader.efi.canTouchEfiVariables = lib.mkDefault true;
        }
      )
      {
        kernelPackages = lib.mkDefault pkgs.linuxPackages;
        initrd.verbose = false;
        tmp.useTmpfs = lib.mkDefault true;
        kernelParams = lib.mkDefault [
          "quiet"
          "udev.log_level=3"
          "iommu=pt" # Fix pour certain cpu AMD
        ];

        initrd.systemd.enable = lib.mkDefault true;
        plymouth.enable = lib.mkDefault true;
      }
    ];
  };
}
