{ config, lib, pkgs, ... }:
let
  cfg = config.winter.programs.arduino;
in {
  options.winter.programs.arduino = {
    enable = lib.mkEnableOption "Enable Arduino dev tools";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users for whom arduino device permissions should be enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.arduino
    ];
    users.users = builtins.listToAttrs (map (user: {
      name = user;
      value.extraGroups = [ "dialout" "uucp" ];
    }) cfg.users);
  };
}
