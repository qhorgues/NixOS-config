{ pkgs, lib, ... }:
{
  hardware.bluetooth.enable = lib.mkForce false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-bluetooth
  ];
}
