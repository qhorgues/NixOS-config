{ pkgs, lib, config, ... }:

let
  cfg = config.winter.lxqt;
in
{
  options.winter.lxqt.enable = lib.mkEnableOption "Enable LXQT desktop environment";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      # displayManager.lightdm.enable = true;
      excludePackages = with pkgs; [
          xterm
      ];
      desktopManager.lxqt.enable = true;
      windowManager.openbox.enable = false;
      xkb = {
          layout = lib.mkDefault "fr";
          variant = "";
      };
    };


    environment.lxqt.excludePackages = with pkgs.lxqt; [
        ### CORE 1
        libfm-qt
        lxqt-about
        lxqt-admin
        lxqt-config
        lxqt-globalkeys
        lxqt-menu-data
        lxqt-notificationd
        lxqt-openssh-askpass
        lxqt-policykit
        lxqt-powermanagement
        lxqt-qtplugin
        lxqt-session
        lxqt-sudo
        lxqt-themes
        lxqt-wayland-session
        pavucontrol-qt

        ### CORE 2
        lxqt-panel
        lxqt-runner
        pcmanfm-qt

        ### LXQt project
        qterminal
        obconf-qt
        lximage-qt
        lxqt-archiver

        ### QtDesktop project
        qps
        screengrab

        ### Default icon theme
        pkgs.kdePackages.breeze-icons

        ### Screen saver
        pkgs.xscreensaver
    ];

    environment.systemPackages = with pkgs.lxqt; [
        lxqt-wayland-session
    ];

    environment.sessionVariables = {
        LXQT_WINDOW_MANAGER = "xfwm4";
    };
  };
}
