{ pkgs, modulixos-config, ... }:
{
  imports = [
    ../../home/quentin
    ./zed-remote-folder.nix
  ];

  mx = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "fw-laptop-16";
    };
    auto-update.enable = true;
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
        inkscape.enable = true;
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
        python = false;
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

  home.file.".config/BOE_CQ_______NE160QDM_NZ6.icm".source = ./BOE_CQ_______NE160QDM_NZ6.icm;

  home.packages = let
    mkGameConfigSwitcher = { ... } @ args: modulixos-config.lib.mkGameConfigSwitcher ({
      inherit pkgs;
      saveBase = "$HOME/kDrive/Documents/Loisirs/Jeux";
      steamLibrary = "/mnt/Games/SteamLibrary";
    } // args);

  in
  [
    pkgs.coe33
    pkgs.video-downloader
    (modulixos-config.lib.igpu-launch {
      inherit pkgs;
      igpuId  = "1002:15bf";
      igpuNumber = "1";
    })
    (mkGameConfigSwitcher {
      game = "aoe4";
      savePath = "AOE4/Config-FW-16";
      steamId = "1466860";
      files = [
        {
          fileName = "configuration_system.lua";
          winPath = "users/steamuser/Documents/My Games/Age of Empires IV";
        }
      ];
    })
    (mkGameConfigSwitcher {
      game = "coe33";
      savePath = "Clair-Obscur_Expedition33/Config-FW-16";
      steamId = "1903340";
      files = [
        {
          fileName = "GameUserSettings.ini";
          winPath = "users/steamuser/AppData/Local/Sandfall/Saved/Config/Windows";
        }
      ];
    })
    (mkGameConfigSwitcher {
      game = "witcher3";
      savePath = "Witcher3/Config-FW-16";
      steamId = "292030";
      files = [
        {
          fileName = "dx12user.settings";
          winPath = "users/steamuser/Documents/The Witcher 3";
        }
      ];
    })
    (mkGameConfigSwitcher {
      game = "ml";
      savePath = "ManorLord/Config-FW-16";
      steamId = "1363080";
      files = [
        {
          fileName = "GameUserSettings.ini";
          winPath = "users/steamuser/AppData/Local/ManorLords/Saved/Config/Windows";
        }
        {
          fileName = "UserSettings.ini";
          winPath = "users/steamuser/AppData/Local/ManorLords/Saved/Config/Windows";
        }
      ];
    })
  ];

  nix.settings.secret-key-files = [ "/etc/nix/signing-key.sec" ];
}
