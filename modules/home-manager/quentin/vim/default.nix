{ config, pkgs, lib, ... }:
let
  cfg = config.winter.programs.vim;
in
{
  options.winter.programs.vim = {
    enable = lib.mkEnableOption "Install Vim";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vim
    ];
  };
}
