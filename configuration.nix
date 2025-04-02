# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;
in

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in


let
  nix-software-center = import (pkgs.fetchFromGitHub {
    owner = "snowfallorg";
    repo = "nix-software-center";
    rev = "0.1.2";
    sha256 = "xiqF1mP8wFubdsAQ1BmfjzCgOD3YZf7EGWl9i69FTls=";
  }) {};
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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


  networking.hostName = "fw-laptop-quentin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
  boot.kernelParams = [ "quiet" ];

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
  services.xserver.enable = false;

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # VM
  security.apparmor.enable = false;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;  # enable copy and paste between host and guest
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
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

  # Steam
  programs = {
    gamescope.enable = true;
    gamemode.enable = true;
    java.enable = true;
    steam = {
      enable = true;
      extest.enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };

  programs.zsh.enable = true;

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

      # Dev
      unstable.	zed-editor
      zeal
      	gaphor
      	jetbrains.idea-community-bin

      # Nix
      nixd # Nix language server for zeditor

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
      
      # Python
      python3

      	# Games
      goverlay
      	adwsteamgtk
      	discord

      # Desktop
      texstudio
      libreoffice-fresh

      # Graphism
      inkscape
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
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
	        blur-my-shell.extensionUuid
	        dash-to-dock.extensionUuid
	        appindicator.extensionUuid
	        removable-drive-menu.extensionUuid
	        caffeine.extensionUuid
	        user-themes.extensionUuid
        ];
      };
      settings."org/gnome/desktop/interface" = {
	      icon-theme = "ePapirus";
        show-battery-percentage = true;
        text-scaling-factor = 0.8;
        toolbar-style = "text";
        gtk-theme = "HighContrastInverse";
      };
      settings."org/gnome/desktop/background" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-l.svg";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/blobs-d.svg";
      };
      settings."org/gnome/desktop/keyboard" = {
        numlock-state = true;
        remember-numlock-state = false;
      };
      settings."org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
      settings."org/gnome/desktop/privacy".hide-identity = true;
      settings."org/gnome/SessionManager".logout-prompt = false;

      settings."org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
      settings."org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;

      settings."org/gnome/shell/extensions/dash-to-dock" = {
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

      settings."org/gnome/TextEditor" = {
        indent-style = "space";
        restore-session = true;
        show-line-numbers = true;
        show-right-margin = false;
        style-scheme = "Adwaita";
        tab-width = lib.hm.gvariant.mkUint32 2;
        use-system-font = true;
      };

      settings."org/gnome/gnome-session".logout-prompt = false;

      settings."org/gnome/shell".favorite-apps = ["firefox.desktop"
                                                  "org.gnome.Nautilus.desktop"
                                                  "org.gnome.Console.desktop"
                                                  "dev.zed.Zed.desktop"
                                                  "org.gnome.TextEditor.desktop"];

    };

      programs = {
        bash.enable = true;
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
    totem # video player
    yelp
    gnome-calculator
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
  ];
  # Install firefox.
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.autoUpgrade.enable = true;
  nix.settings.auto-optimise-store = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager

    # Tools
    fastfetch
    htmlq
    htop
    gnome-software
    gnome-tweaks
    dconf-editor
    gnome-extension-manager
    nix-software-center
    steam-run # For launch single executable (no connection with valve)
    pciutils
  ];

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
