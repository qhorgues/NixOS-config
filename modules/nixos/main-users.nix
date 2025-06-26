{ pkgs, lib, config, ... }:

let
  cfg = config.winter.main-user;
in
{
  options = {
    winter.main-user.enable = lib.mkEnableOption "enable user module";

    winter.main-user.userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = "1234";
      description = "main user";
      shell = pkgs.zsh;
    };
  };
}
