{ config, lib, ... }:

let
  cfg = config.mx.programs.git;
in
{
  options.mx.programs.git = {
    enable = lib.mkEnableOption "Enable git with config";
  };

  config = lib.mkIf (config.mx.programs.dev.enable || cfg.enable) {
    programs.git = {
      enable = true;
      settings.user = {
        name  = "qhorgues";
        email = "quentin.horgues@outlook.fr";
      };
    };
  };
}
