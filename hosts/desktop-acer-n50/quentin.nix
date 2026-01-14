{ ... }:
{
  imports = [
    ../../modules/home-manager
    ./home-manager/zed-remote-folder.nix
  ];

  winter = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "desktop-acer-n50";
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
