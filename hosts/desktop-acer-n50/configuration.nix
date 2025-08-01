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
        ../../modules/nixos/nvidia-standby-fix.nix
        ../../modules/nixos/fonts
        ../../modules/nixos/gnome
        ../../modules/nixos/boot.nix
        ../../modules/nixos/common.nix
        ../../modules/nixos/main-users.nix
        ../../modules/nixos/sound.nix
        ../../modules/nixos/security.nix
        ../../modules/nixos/zram.nix
        ../../modules/nixos/games.nix
        ../../modules/nixos/update.nix
        ../../modules/nixos/disable-bluetooth.nix
        ../../modules/nixos/vm.nix
        ../../modules/nixos/mariadb.nix
        ../../modules/nixos/ios-connect.nix
    ];

    hardware.nvidia.open = false;
    networking.hostName = "desktop-quentin";

    fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
    fileSystems."/home".options = [ "noatime" "nodiratime" "discard" "defaults" ];
    fileSystems."/mnt/Games" =
    { device = "/dev/disk/by-uuid/6c951fd8-2e7f-41aa-91c6-abb520e39af5";
        fsType = "ext4";
        options = [ "noatime" "nodiratime" "discard" ];
    };

    systemd.tmpfiles.rules = [
        "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}"
    ];

    winter = {
        nvidia.standby = {
            enable = true;
            old-gpu = true;
        };
        main-user = {
            enable = true;
            userName = "quentin";
            userFullName = "Quentin Horgues";
        };
    };

    home-manager = {
        extraSpecialArgs = { inherit self inputs pkgs pkgs-unstable; };
        users = {
        "quentin" = import ./quentin.nix;
        "elise" = import ./elise.nix;
        };
    };

    winter.vm = {
        users = [ "quentin" ];
        # platform = "intel";
        # vfioIds = [ "10de:1c82" "10de:0fb9" ];
    };

    users.users."elise"= {
      isNormalUser = true;
      initialPassword = "1234";
      description = "Elise Horgues";
      extraGroups = [ "networkmanager" ];
    };
}
