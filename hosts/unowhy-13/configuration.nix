{ self, config, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        ./hardware-configuration.nix
        ../../modules/nixos/core
        ../../modules/nixos/fonts
        ../../modules/nixos/gnome
        ../../modules/nixos/main-users.nix
        ../../modules/nixos/disable-bluetooth.nix
        # ../../modules/nixos/powersave.nix
        #../../modules/nixos/ios-connect.nix
        # ../../modules/nixos/mariadb.nix
    ];

    networking.hostName = "uw-laptop-quentin";
    boot.tmp.useTmpfs = true;
    boot.kernelPackages = pkgs.linuxPackages;
    fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];

    winter = {
        main-user = {
            enable = true;
            userName = "quentin";
            userFullName = "Quentin Horgues";
        };
        gnome = {
            text-scaling = 1.2;
            numlock = false;
        };
    };

    home-manager = {
      extraSpecialArgs = {
          inherit self inputs pkgs pkgs-unstable;
      };
      users = {
          "quentin" = import ./quentin.nix;
      };
    };
}
