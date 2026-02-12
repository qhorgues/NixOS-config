{ config, pkgs, lib, ... }:
let
  cfg = config.winter.programs.thunderbird;
in
{
  options.winter.programs.thunderbird = {
    enable = lib.mkEnableOption "Install thunderbird";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      thunderbird-latest-bin
    ];
  };
}
