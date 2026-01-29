{ self, pkgs, inputs, pkgs-unstable, ... }:

let
    monitorsXmlContent = builtins.readFile ./monitors.xml;
    monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in
{
    imports = [
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        inputs.nixos-hardware.nixosModules.common-pc-ssd
        inputs.nixos-hardware.nixosModules.common-pc
        ./hardware-configuration.nix
    ];

    hardware.nvidia.open = false;
    networking.hostName = "desktop-quentin";

    fileSystems."/mnt/Games" =
    { device = "/dev/disk/by-uuid/6c951fd8-2e7f-41aa-91c6-abb520e39af5";
        fsType = "ext4";
    };

    systemd.tmpfiles.rules = [
        "L+ /var/lib/gdm/seat0/config/monitors.xml - gdm gdm - ${monitorsConfig}"
    ];

    winter = {
      hardware = {
        gpu = {
          vendor = "nvidia";
          acceleration = "cuda";
          frame-generation.enable = false;
          generation = "pascal";
          nvidia.standby = {
            enable = true;
            old-gpu = true;
          };
        };
        bluetooth.enable = false;
        ssd.lists = [ "/" "/mnt/Games" ];
      };
      main-user = {
        enable = true;
        userName = "quentin";
        userFullName = "Quentin Horgues";
      };
      gnome = {
        enable = true;
      };
      services = {
        vm = {
          enable = true;
          users = [ "quentin" ];
        };
        docker = {
          enable = false;
          users = [ "quentin" ];
        };
        apache-php-mariadb.enable = false;
        postgresql.enable = false;
      };
      programs = {
        games.enable = true;
      };
    };

    users.users."elise"= {
      isNormalUser = true;
      initialPassword = "1234";
      description = "Elise Horgues";
      extraGroups = [ "networkmanager" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
          inherit self inputs pkgs pkgs-unstable;
      };
      users = {
      "quentin" = import ./quentin.nix;
      "elise" = import ./elise.nix;
      };
    };
}
