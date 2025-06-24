{ pkgs, nixos-hardware, ... }:

let
  monitorsXmlContent = builtins.readFile ./screen/desktop-acer-n50.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in
{
  imports = [
    nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc
    ./hardware/desktop-acer-n50.nix
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
    ../modules/games.nix
    ../modules/graphism.nix
    ../modules/update.nix
    ../modules/disable-bluetooth.nix
    ../modules/kdrive.nix
    ../modules/vm.nix
  ];

  networking.hostName = "desktop-quentin";
  hardware.nvidia.open = false;
  boot.kernelPackages = pkgs.linuxPackages;
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

  winter.nvidia.standBy = true;
  winter.vm = {
    users = [ "quentin" ];
    platform = "intel";
    vfioIds = [ "10de:1c82" "10de:0fb9" ];
  };
}
