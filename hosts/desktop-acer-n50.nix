{ pkgs, nixos-hardware, ... }:
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
    ../modules/users.nix
    ../modules/sound.nix
    ../modules/desktop-gnome.nix
    ../modules/security.nix
    ../modules/zram.nix
    ../modules/games.nix
    ../modules/update.nix
    ../modules/disable-bluetooth.nix
  ];

  hardware.nvidia.open = false;
  boot.kernelPackages = pkgs.linuxPackages;
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" "defaults" ];
}
