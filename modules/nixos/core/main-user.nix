{ pkgs, config, secretsPath, ... }:

let
  cfg = config.mx.main-user;

in
{
    age.secrets.quentin-password = {
      file = "${secretsPath}/shared/quentin-password.age";
      owner = "root";
      mode  = "0400";
    };

    users.users.quentin = {
      isNormalUser = true;
      description = "Quentin Horgues";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
      hashedPasswordFile = config.age.secrets.quentin-password.path;
    };
    programs.zsh.enable = true;
}
