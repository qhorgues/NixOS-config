{ config, lib, ... }:

let
  cfg = config.winter.services.docker;
in
{
  options.winter.services.docker = {
    enable = lib.mkEnableOption "Enable docker service";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users can run and setup docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      rootless.enable = true;
    };

    users.users = builtins.listToAttrs (map (user: {
      name = user;
      value.extraGroups = [ "docker" ];
    }) cfg.users);
  };
}
