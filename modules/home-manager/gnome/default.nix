{ pkgs, lib, config, ... }:
{
    imports = [
        ./mineapps.nix
    ];

    home.packages = with pkgs; [
        # Base gnome app
        gnome-tweaks
        gnome-console
        gnome-text-editor
        gnome-calculator
        gnome-music
        showtime
        papers
        file-roller
        nautilus
        loupe
        gnome-extension-manager
        decibels
        # Extension
        gnomeExtensions.dash-to-dock
        gnomeExtensions.blur-my-shell
        gnomeExtensions.appindicator
        gnomeExtensions.removable-drive-menu
        gnomeExtensions.caffeine
        gnomeExtensions.places-status-indicator
        gnomeExtensions.quick-settings-audio-panel
        gnomeExtensions.gsconnect
        # gnomeExtensions.tiling-shell
        # Icons
        papirus-icon-theme
        # (import ../../../pkgs/winteros-icons.nix {inherit pkgs;})
    ]; # ++ lib.optional osConfig.winter.hardware.framework-fan-ctrl.enable pkgs.gnomeExtensions.fw-fanctrl;
    dconf = {
        enable = true;
        settings = {
        "org/gnome/shell" = {
            disable-user-extensions = false;
            enabled-extensions = with pkgs.gnomeExtensions; [
              blur-my-shell.extensionUuid
              dash-to-dock.extensionUuid
              appindicator.extensionUuid
              removable-drive-menu.extensionUuid
              caffeine.extensionUuid
              places-status-indicator.extensionUuid
              quick-settings-audio-panel.extensionUuid
              gsconnect.extensionUuid
              # tiling-shell.extensionUuid
            ];# ++ lib.optional osConfig.winter.hardware.framework-fan-ctrl.enable       pkgs.gnomeExtensions.fw-fanctrl.extensionUuid;
            favorite-apps = [
              "firefox.desktop"
              "org.gnome.Nautilus.desktop"
              "org.gnome.Console.desktop"
              "dev.zed.Zed.desktop"
              "org.gnome.TextEditor.desktop"
            ];
        };
        "org/gnome/desktop/interface" = {
            icon-theme = "Papirus"; # "WinterOS-icons";
            show-battery-percentage = true;
            toolbar-style = "text";
            gtk-theme = "Adwaita";
            enable-hot-corners = false;
        };
        "org/gnome/desktop/background" = {
            picture-uri =  "file://${config.home.homeDirectory}/.local/share/wallpaper/clair-obscur.jpg";
            picture-uri-dark = "file://${config.home.homeDirectory}/.local/share/wallpaper/clair-obscur.jpg";
        };
        "org/gnome/desktop/wm/preferences" = {
            button-layout = "appmenu:minimize,maximize,close";
        };
        "org/desktop/vm/preferences" = {
            button-layout = "appmenu:minimize,maximize,close";
        };
        "org/gnome/desktop/peripherals/touchpad" = {
            click-method = "areas";
            natural-scroll = false;
            disable-while-typing = true;
        };
        "org/gnome/desktop/privacy".hide-identity = true;
        "org/gnome/SessionManager".logout-prompt = false;
        "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
        "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;
        "org/gnome/shell/extensions/dash-to-dock" = {
            blur = false;
           	autohide = true;
            background-opacity = 0.8;
            custom-theme-shrink = false;
            dash-max-icon-size = 48;
            dock-fixed = false;
            dock-position = "BOTTOM";
            extend-height = false;
            height-fraction = 0.9;
            intellihide = true;
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
        # "org/gnome/shell/extensions/tilingshell" = {
        #     enable-autotiling = true;
        #     show-indicator = false;
        #     enable-screen-edges-windows-suggestions = true;
        #     enable-smart-window-border-radius = true;
        #     enable-snap-assistant-windows-suggestions = true;
        #     enable-tiling-system-windows-suggestions = true;
        #     enable-window-border = false;
        #     focus-window-down = ["<Control><Super>Down"];
        #     focus-window-left = ["<Control><Super>Left"];
        #     focus-window-right = ["<Control><Super>Right"];
        #     focus-window-up = ["<Control><Super>Up"];
        #     highlight-current-window = ["''"];
        #     inner-gaps = lib.hm.gvariant.mkUint32 6;
        #     snap-assistant-threshold = lib.hm.gvariant.mkInt32 20;
        #     layouts-json = builtins.toJSON [
        #         {
        #             id =  "2 windows";
        #             tiles = [
        #                 {
        #                     x = 0;
        #                     y = 0;
        #                     width = 0.5663145539906104;
        #                     height = 1;
        #                     groups = [1];
        #                 }
        #                 {
        #                     x = 0.5663145539906104;
        #                     y = 0;
        #                     width = 0.4336854460093899;
        #                     height = 1;
        #                     groups = [2 1];
        #                 }
        #             ];
        #         }
        #         {
        #             id =  "3 windows";
        #             tiles = [
        #                 {
        #                     x = 0;
        #                     y = 0;
        #                     width = 0.5663145539906104;
        #                     height = 1;
        #                     groups = [1];
        #                 }
        #                 {
        #                     x = 0.5663145539906104;
        #                     y = 0;
        #                     width = 0.4336854460093899;
        #                     height = 0.4995159728944821;
        #                     groups = [2 1];
        #                 }
        #                 {
        #                     x = 0.5663145539906104;
        #                     y = 0.4995159728944821;
        #                     width = 0.4336854460093899;
        #                     height = 0.500484027105518;
        #                     groups = [2 1];
        #                 }
        #             ];
        #         }
        #     ];
        #     selected-layouts = [["2 windows"] ["2 windows"]];
        #     outer-gaps = lib.hm.gvariant.mkUint32 6;
        #     overriden-window-menu = false;
        #     top-edge-maximise = true;
        #     untile-window = ["<Super>d"];
        # };
        "org/gnome/TextEditor" = {
            indent-style = "space";
            restore-session = true;
            show-line-numbers = true;
            show-right-margin = false;
            style-scheme = "Adwaita";
            tab-width = lib.hm.gvariant.mkUint32 2;
            use-system-font = true;
        };
        "org/gnome/nautilus/list-view".use-tree-view = true;
        "org/gnome/gnome-session".logout-prompt = false;
        "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
        };
        "org/gnome/Console" = {
            theme = "auto";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Control>MonBrightnessDown";
            command = "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 1";
            name = "Eteindre l'ecran";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "<Control>MonBrightnessUp";
            command = "busctl --user set-property org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.gnome.Mutter.DisplayConfig PowerSaveMode i 0";
            name = "Allumer l'ecran";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            binding = "<Control><Alt>t";
            command = "kgx";
            name = "Terminal";
        };
        "org/gnome/desktop/input-sources" = {
            sources = [
                (lib.gvariant.mkTuple["xkb" "fr+oss"])
            ];
        };
        };
    };
    home.file.".local/share/wallpaper/clair-obscur.jpg".source = ./clair-obscur.jpg;
}
