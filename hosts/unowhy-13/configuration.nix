{ self, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        ./hardware-configuration.nix
    ];

    networking.hostName = "uw-laptop-quentin";
    boot.tmp.useTmpfs = true;
    boot.kernelPackages = pkgs.linuxPackages;
    fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];

    winter = {
      hardware.bluetooth.enable = false;
      main-user = {
        enable = true;
        userName = "quentin";
        userFullName = "Quentin Horgues";
      };
      gnome = {
        enable = true;
        scaling = 2;
        text-scaling = 0.7;
      };
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
          inherit self inputs pkgs pkgs-unstable;
      };
      users = {
          "quentin" = import ./quentin.nix;
      };
    };
}
