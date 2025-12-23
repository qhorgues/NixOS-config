{ pkgs, winapps, ... }:
{
  imports = [
    ./vm.nix
  ];
  environment.systemPackages = [
    winapps.winapps
    winapps.winapps-launcher
    pkgs.virtio-win
  ];
}
