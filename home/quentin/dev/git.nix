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
      settings = {
        user = {
          name  = "qhorgues";
          email = "quentin.horgues@outlook.fr";
        };
        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
        init.defaultBranch = "main";
      };
      signing = {
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
    };
    home.file.".config/git/allowed_signers".text =
      "quentin.horgues@outlook.fr ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeDXES7JVBTFfXQTezi08nO8GQpWTiQP/myoLfpTAtD";
  };

}
