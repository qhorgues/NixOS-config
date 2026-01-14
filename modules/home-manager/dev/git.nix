{ config, lib, ... }:

let
  cfg = config.winter.programs.git;
in
{
  options.winter.programs.git = {
    enable = lib.mkEnableOption "Enable git with config";
  };

  config = lib.mkIf (config.winter.programs.dev.enable || cfg.enable) {
    programs.git = {
      enable = true;
      settings.user = {
        name  = "qhorgues";
        email = "quentin.horgues@outlook.fr";
      };
    };
  };
}
