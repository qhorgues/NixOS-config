# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  unstableTarball = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./framework-16.nix
      (import "${home-manager}/nixos")
    ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "fw-laptop-quentin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader= {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true;
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
    binfmt.emulatedSystems = ["aarch64-linux"];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    excludePackages = with pkgs; [
      xterm
    ];
    desktopManager.gnome.enable = true;
  };
  # services.gnome.gnome-keyring.enable = lib.mkForce false;

  # VM
  security.apparmor.enable = false;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;  # enable copy and paste between host and guest
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs = {
    zsh.enable = true;
    firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
    };

    dconf.profiles.gdm.databases = [{
      settings = {
        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
          remember-numlock-state = true;
        };
        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
        };
        "org/gnome/desktop/interface" = {
          scaling-factor = lib.gvariant.mkUint32 2;
          icon-theme = "ePapirus";
          show-battery-percentage = true;
          text-scaling-factor = 0.8;
        };
      };
    }];

    nix-ld.enable = true;

    # Games
    gamescope.enable = true;
    gamemode.enable = true;
    steam = {
      gamescopeSession.enable = true;
      enable = true;
      extest.enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        unstable.proton-ge-bin
      ];
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
        };
      };
    };
  };
  environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      MANGOHUD_CONFIG = "control=mangohud,hud_no_margin,legacy_layout=false,horizontal,background_alpha=0.6,round_corners=0,background_alpha=0.2,background_color=000000,font_size=24,text_color=FFFFFF,position=top-center,toggle_hud=Shift_R+F12,no_display,table_columns=1,gpu_text=GPU,gpu_stats,gpu_temp,gpu_power,gpu_color=2E9762,cpu_text=CPU,cpu_stats,cpu_temp,cpu_power,cpu_color=2E97CB,vram,vram_color=AD64C1,vram_color=AD64C1,ram,ram_color=C26693,battery,battery_color=00FF00,fps,gpu_name,wine,wine_color=EB5B5B,fps_limit_method=late,toggle_fps_limit=Shift_L+F1,fps_limit=0,time";
    };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.quentin = {
    isNormalUser = true;
    description = "Quentin Horgues";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.zsh;


    packages = with pkgs; [
      # Gnome extension
      gnomeExtensions.dash-to-dock
      gnomeExtensions.blur-my-shell
      gnomeExtensions.appindicator
      gnomeExtensions.removable-drive-menu
      gnomeExtensions.caffeine
      gnomeExtensions.user-themes

      # Icons
      unstable.epapirus-icon-theme

      # VM
      virt-manager

      ventoy-full

      # Dev
      unstable.	zed-editor
      zeal
      gaphor
      jetbrains.idea-community-bin
      git

      # Nix
      nixd # Nix language server for zeditor
      nil

      # C / C++
      gcc
      clang-tools
      clang
      cmake
      gnumake

      # Rust
      cargo
      rustc
      rustup
      rust-analyzer

      # Python
      python3
      uv
      ruff

      # Games
      adwsteamgtk
      discord
      # openrgb

      # Desktop
      texstudio
      libreoffice-fresh

      # Graphism
      inkscape
      unstable.gimp3
      krita

      kdenlive

      # gdm-settings
    ];
  };
  home-manager.users.quentin = { pkgs, lib, ... }: {
    # Pointer settings for VM
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
    home.packages = [];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
          remember-numlock-state = true;
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
	          blur-my-shell.extensionUuid
	          dash-to-dock.extensionUuid
	          appindicator.extensionUuid
	          removable-drive-menu.extensionUuid
	          caffeine.extensionUuid
	          user-themes.extensionUuid
          ];
          favorite-apps = ["firefox.desktop"
                           "org.gnome.Nautilus.desktop"
                           "org.gnome.Console.desktop"
                           "dev.zed.Zed.desktop"
                           "org.gnome.TextEditor.desktop"];
        };
        "org/gnome/desktop/interface" = {
          icon-theme = "ePapirus";
          show-battery-percentage = true;
          scaling-factor = lib.hm.gvariant.mkUint32 2;
          text-scaling-factor = 0.8;
          toolbar-style = "text";
          gtk-theme = "HighContrastInverse";
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
          picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
        };
        "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
        "org/gnome/desktop/privacy".hide-identity = true;
        "org/gnome/SessionManager".logout-prompt = false;
        "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
        "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;
        "org/gnome/shell/extensions/dash-to-dock" = {
         	autohide = true;
          background-opacity = 0.8;
          custom-theme-shrink = false;
	        dash-max-icon-size = 48;
	        dock-fixed = false;
	        dock-position = "BOTTOM";
	        extend-height = false;
	        height-fraction = 0.9;
	        intellihide = false;
	        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
	        multi-monitor = true;
	        preferred-monitor = -2;
	        scroll-to-focused-applications = true;
	        show-icons-emblems = true;
	        show-icons-network = false;
	        show-mounts = false;
	        show-mounts-neetwork = false;
	        show-mounts-only-mounted = true;
	        show-running = true;
	        show-show-apps-button = false;
	        show-trash = false;
	        transparency-mode = "DEFAULT";
        };
        "org/gnome/TextEditor" = {
          indent-style = "space";
          restore-session = true;
          show-line-numbers = true;
          show-right-margin = false;
          style-scheme = "Adwaita";
          tab-width = lib.hm.gvariant.mkUint32 2;
          use-system-font = true;
        };
        "org/gnome/gnome-session".logout-prompt = false;
      };
    };

      programs = {
        git = {
          enable = true;
	        userName  = "Quentin Horgues";
	        userEmail = "quentin.horgues@ikmail.com";
        };
	      zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          shellAliases = {
            ll = "ls -l";
            update = "sudo nix-channel --update
                      sudo nix-env -u --always
                      sudo nixos-rebuild boot --upgrade-all
                      sudo rm /nix/var/nix/gcroots/auto/*
                      sudo nix-store --gc
                      sudo nix-collect-garbage -d
                      ";
          };
          history.size = 10000;
          oh-my-zsh = {
            enable = true;
            plugins = [ "git" ];
            theme = "robbyrussell";
          };
        };
      };
      home.stateVersion = config.system.nixos.release;

  };

  # Pour davinci
  # hardware.amdgpu.opencl.enable=true;

  environment.gnome.excludePackages = with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    # baobab
    snapshot
    simple-scan
    eog
    file-roller
    seahorse
    epiphany # web browser
    # evince # document viewer
    geary # email reader
    gnome-characters
    # gnome-music
    gnome-photos
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    # totem # video player
    yelp
    # gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-screenshot
    gnome-system-monitor
    gnome-weather
    gnome-connections
    gnomeExtensions.auto-move-windows
    gnome-software
    gnome-disk-utility
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;

  /* services.ollama = {
      enable = true;
      acceleration = "rocm";
      # Optional: preload models, see https://ollama.com/library
      loadModels = [ "llama3.2:3b" ];
    };
  services.open-webui.enable = true;*/

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager

    # Tools
    git
    fastfetch
    htop
    gnome-tweaks
    dconf-editor
    gnome-extension-manager
    steam-run # For launch single executable (no connection with valve)
    pciutils

    # Games
    mangohud

    # ollama
    # open-webui
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 5;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = config.system.nixos.release; # Did you read the comment?
}
