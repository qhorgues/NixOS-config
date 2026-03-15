{ pkgs, lib, config, ... }:

let
  cfg = config.mx.main-user;
in
{
  options = {
    mx.main-user.enable = lib.mkEnableOption "enable user module";

    mx.main-user.userName = lib.mkOption {
      default = "mainuser";
      description = ''
        username
      '';
    };

    mx.main-user.userFullName = lib.mkOption {
      default = ''main user'';
      description = ''
        full username
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      initialPassword = "1234";
      description = cfg.userFullName;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
  };
}
