{ self, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        ./hardware-configuration.nix
    ];

    networking.hostName = "uw-laptop-quentin";

    winter = {
      core.network.security-mode = true;
      hardware = {
        bluetooth.enable = false;
        ssd.lists = [ "/" ];
      };
      main-user = {
        enable = true;
        userName = "quentin";
        userFullName = "Quentin Horgues";
      };
      gnome.enable = true;
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
