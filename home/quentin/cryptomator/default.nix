{ config, lib, pkgs, ... }:

let
  cfg = config.mx.programs.cryptomator;
in
{
  options.mx.programs.cryptomator = {
    enable = lib.mkEnableOption "Install Cryptomator";
  };

  config =  lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cryptomator
    ];
  };
}
