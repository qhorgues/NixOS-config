{ config, pkgs, lib, ... }:
let
  cfg = config.mx.programs.vim;
in
{
  options.mx.programs.vim = {
    enable = lib.mkEnableOption "Install Vim";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vim
    ];
  };
}
