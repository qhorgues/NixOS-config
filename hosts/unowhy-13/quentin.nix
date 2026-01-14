{ ... }:
{
  imports = [
    ../../modules/home-manager
    ../../modules/home-manager/linux-base-app.nix
    ../../modules/home-manager/common-app.nix
    ../../modules/home-manager/firefox
    ../../modules/home-manager/gnome
    ../../modules/home-manager/kdrive.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/thunderbird.nix
    ../../modules/home-manager/flake-script.nix
    ../../modules/home-manager/discord.nix
  ];

  winter = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "unowhy-13";
    };
    auto-update.enable = true;
    programs = {
      firefox.enable = true;
      thunderbird.enable = true;
      office.enable = false;
      discord.enable = true;
      zed-editor.enable = true;
      vscode.enable = false;
      kdrive.enable = true;
      graphism.enable = false;
      git.enable = true;
      vim.enable = false;
      linux-base-tools.enable = true;
      dev = {
        enable = true;
        nix = true;
        cpp = true;
        rust = true;
        python = false;
        node = false;
        php = false;
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
}
