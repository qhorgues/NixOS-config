{ pkgs, lib, ... }:
{
    services = {
        xserver = {
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
    };

    environment.systemPackages = with pkgs; [
        xfce.xfwm4
        lxqt.lxqt-session
        lxqt.lxqt-config
        lxqt.lxqt-panel
        lxqt.pcmanfm-qt
        lxqt.qterminal
    ];

    environment.sessionVariables = {
        LXQT_WINDOW_MANAGER = "xfwm4";
    };
}
