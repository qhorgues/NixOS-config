{ inputs, pkgs, ... }:
{
  imports = [
    ../../modules/home-manager
    ./home-manager/zed-remote-folder.nix
  ];

  winter = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "fw-laptop-16";
    };
    auto-update.enable = true;
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
      office.enable = false;
      discord.enable = true;
      zed-editor.enable = true;
      ssh.enable = true;
      vscode.enable = false;
      kdrive.enable = true;
      graphism.enable = true;
      git.enable = true;
      vim.enable = false;
      linux-base-tools.enable = true;
      winboat.enable = true;
      dev = {
        enable = true;
        nix = true;
        cpp = true;
        rust = true;
        python = true;
        node = true;
        php = true;
        gnome-dev = false;
      };
    };
  };

  home.username = "quentin";
  home.homeDirectory = "/home/quentin";
  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };

  home.file.".config/BOE_CQ_______NE160QDM_NZ6.icm".source = ./home-manager/BOE_CQ_______NE160QDM_NZ6.icm;



  home.packages = [
    inputs.coe33.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
