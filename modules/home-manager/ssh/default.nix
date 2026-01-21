{ config, lib, ... }:

let
  cfg = config.winter.programs.ssh;
in
{
  imports = [
    ./ssh-config.nix
  ];

  options.winter.programs.ssh = {
    enable = lib.mkEnableOption "Enable ssh client";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
