{ lib, ... }:
{
  imports = [
    ./hardware-gpu.nix
    ./framework.nix
  ];

  # General internal options
  options.mx = {
    programs._studio.enable = lib.mkEnableOption "Enable Studio optimization";
  };
}
