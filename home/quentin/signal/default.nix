{ config, lib, pkgs, ... }:

{
  options.mx.programs.signal = {
    enable = lib.mkEnableOption "Install Signal client";
  };

  config = lib.mkIf config.mx.programs.signal.enable {
    home.packages = [
      pkgs.signal-desktop
    ];
  };
}
