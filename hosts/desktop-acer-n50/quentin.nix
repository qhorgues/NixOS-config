{ pkgs, ... }:
{
  imports = [
    ../../home/quentin
    ./zed-remote-folder.nix
  ];

  mx = {
    update = {
        flake_path = "/home/quentin/Programmes/Nix/NixOS-config";
        flake_config = "desktop-acer-n50";
    };
    auto-update.enable = true;
    xdg.mimeApps.enable = true; # Manage ~/.config/mimeapps.list declaratively
    desktop-environment.gnome = {
      connection = false;
      live-wallpaper = true;
    };
    programs = {
      firefox.enable = true; # Install firefox pre setup
      thunderbird.enable = true; # # Install thunderbird
      cryptomator.enable = true; # Install cryptomator
      # Install all office tools (libre office, only office, latex studio)
      office = {
        libre-office.enable = false;
        latex.enable = true;
        onlyoffice.enable = true;
      };
      signal.enable = true;
      discord.enable = true; # Install discord flatpak
      element.enable = true; # Install Element flatpak
      audio-enhancer.enable = false; # Install audio enhancer with custom profiles
      zed-editor.enable = true; # Install custom zed editor
      ssh.enable = true; # Install ssh client
      vscode.enable = false; # Install custom VS Code
      kdrive.enable = true; # Install kdrive
      # Install graphism tools (GIMP, Krita, Inkscape)
      graphism = {
        gimp.enable = true;
        krita.enable = false;
        inkscape.enable = false;
      };
      git.enable = true; # Install git with config
      vim.enable = false; # Install vim
      linux-base-tools.enable = true; # Install linux base tools (htop, fastfetch, ...)
      winboat.enable = false; # Install Winboat /!\ NEED ENABLE DOCKER ON SYSTEM CONFIG

      # Enable dev tools
      dev = {
        enable = true;
        nix = true;
        cpp = true;
        mpi-lib = false;
        openmp-lib = false;
        rust = true;
        python = true;
        node = true;
        php = false;
        sql = true;
        java = false;
        gnome-dev = false;
        ci = false;
      };
    };
  };

  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };

  home.packages =
  [
    pkgs.coe33
  ];
}
