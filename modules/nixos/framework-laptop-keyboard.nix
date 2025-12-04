{ pkgs, ... }:

let
  qmk = pkgs.callPackage ../../pkgs/framework-qmk-firmware.nix { };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      qmk = qmk;
    })
  ];
  environment.systemPackages = [
    qmk
  ];
  hardware.keyboard.qmk.enable = true;
}
