{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.cryptomator;
in
{
  options.winter.programs.cryptomator = {
    enable = lib.mkEnableOption "Install Cryptomator";
  };

  config =  lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cryptomator
    ];
  };
}
