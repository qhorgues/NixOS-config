{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.common-gpu-nvidia
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc-hdd
    nixos-hardware.nixosModules.common-pc
    ./hardware/fw-laptop-16.nix
    ../modules/bootloader.nix
    ../modules/common.nix
    ../modules/fonts.nix
    ../modules/firefox.nix
    ../modules/users.nix
    ../modules/sound.nix
    ../modules/desktop-gnome.nix
    ../modules/security.nix
    # ../modules/vm.nix
    ../modules/zram.nix
    ../modules/games.nix
    ../modules/update.nix
    # ../modules/zuka_bot.nix
    ../modules/disable-bluetooth.nix
  ];

  hardware.nvidia.open = false;

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
  fileSystems."/home" =
  { device = "/dev/disk/by-uuid/<uuid>";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
}
