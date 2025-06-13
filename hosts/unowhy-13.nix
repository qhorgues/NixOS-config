{ pkgs, nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    ./hardware/unowhy-13.nix
    ../modules/bootloader.nix
    ../modules/common.nix
    ../modules/fonts.nix
    ../modules/firefox.nix
    ../modules/dev.nix
    ../modules/users.nix
    ../modules/sound.nix
    ../modules/desktop-gnome.nix
    ../modules/security.nix
    ../modules/zram.nix
    ../modules/update.nix
    ../modules/disable-bluetooth.nix
    ../modules/kdrive.nix
  ];

  networking.hostName = "uw-laptop-quentin";
  boot.tmp.useTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages;
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
  enableNumlockConfig = false;

  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [{
        settings."org/gnome/desktop/interface" = {
          text-scaling-factor = 1.2;
        };
    }];
    profiles.users.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
            text-scaling-factor =  1.2;
        };
      };
    }];
  };
}
