{ config, lib, ... }:

let
  cfg = config.mx.programs.ssh;
in
{
  imports = [
    ./ssh-config.nix
  ];

  options.mx.programs.ssh = {
    enable = lib.mkEnableOption "Enable ssh client";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
