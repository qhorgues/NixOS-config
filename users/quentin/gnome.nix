{ pkgs, pkgs-unstable, lib, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.caffeine
    gnomeExtensions.user-themes
    # Icons
    pkgs-unstable.epapirus-icon-theme
  ];

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
        toolbar-style = "text";
        gtk-theme = "Adwaita";
        enable-hot-corners = false;
      };
      "org/gnome/desktop/background" = {
        picture-uri =  "file:///run/current-system/sw/share/backgrounds/gnome/amber-l.jxl";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/amber-d.jxl";
      };
      "org/desktop/vm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = false;
        disable-while-typing = true;
      };
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
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
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
        binding = "<Control><Alt>T";
        command = "kgx";
        name = "Terminal";
      };
    };
  };
}
