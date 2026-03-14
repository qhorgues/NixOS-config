{ config, pkgs, lib, ... }:
let
  cfg = config.mx.programs.thunderbird;
in
{
  options.mx.programs.thunderbird = {
    enable = lib.mkEnableOption "Install thunderbird";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      thunderbird-latest-bin
    ];
  };
}
