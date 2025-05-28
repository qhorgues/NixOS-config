{ config, pkgs, ... }:

{
  users.users.quentin = {
    isNormalUser = true;
    description = "Quentin Horgues";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.zsh;
  };
}
