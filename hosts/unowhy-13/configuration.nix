{ self, inputs, pkgs, pkgs-unstable, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ./hardware-configuration.nix
    ../../modules/nixos/fonts
    ../../modules/nixos/gnome
    ../../modules/nixos/boot.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/main-users.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/zram.nix
    ../../modules/nixos/update.nix
    ../../modules/nixos/disable-bluetooth.nix
    ../../modules/nixos/powersave.nix
    ../../modules/nixos/ios-connect.nix
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

  winter.main-user = {
    enable = true;
    userName = "quentin";
    userFullName = "Quentin Horgues";
  };

  home-manager = {
    extraSpecialArgs = { inherit self inputs pkgs-unstable; };
    users = {
      "quentin" = import ./quentin.nix;
    };
  };
}
