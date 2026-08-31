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
  config = lib.mkMerge [
    (
      lib.mkIf cfg.enable {
        boot.loader.limine = {
          enable = true;
          maxGenerations = 10;
          secureBoot = {
            enable = true;
            autoGenerateKeys = true;
            autoEnrollKeys = {
              enable = true;
              extraArgs = [
                "--microsoft"
                "--firmware-builtin"
              ];
            };
          };
          extraConfig = ''
            timeout: 1
            quiet: yes
            remember_last_entry: no
          '';
        };

        boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      }
    )
    {
      boot = {
        kernelPackages = lib.mkDefault pkgs.linuxPackages;
        initrd.verbose = false;
        tmp.useTmpfs = lib.mkDefault true;
        kernelParams = lib.mkDefault [
          "quiet"
          "udev.log_level=3"
          "iommu=pt" # Fix pour certain cpu AMD
        ];

        initrd.systemd.enable = lib.mkDefault true;
        plymouth.enable = lib.mkDefault (!config.mx.mode.server.enable);

        initrd.systemd.tpm2.enable = true;
        initrd.systemd.services.systemd-udev-settle.enable = lib.mkForce false;
      };
      # Fastest boot
      systemd.network.wait-online.enable = false;
      systemd.services.systemd-udev-settle.enable = lib.mkForce false;


    }
  ];
}
