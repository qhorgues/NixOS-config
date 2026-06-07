{ config, lib, ... }:

let
  cfg = config.mx.programs.ssh;
in
{
  imports = [
  ] ++ lib.optionals (lib.versionAtLeast lib.version "26.05") [
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
