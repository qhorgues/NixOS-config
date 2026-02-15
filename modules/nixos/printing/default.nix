{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.winter.services.printing;
  all_users = builtins.attrNames config.users.users;
  normal_users = builtins.filter (user: config.users.users.${user}.isNormalUser) all_users;
in
{
  options.winter.services.printing = {
    enable = lib.mkEnableOption "Enable printer services";
  };

  config = lib.mkIf cfg.enable {
    services = {
      printing = {
        enable = true;
        startWhenNeeded = true;
        drivers = with pkgs; [
          brgenml1cupswrapper
          brgenml1lpr
          brlaser
          cnijfilter2
          epkowa
          gutenprint
          gutenprint-bin
          gutenprintBin
          hplip
          epson-escpr2
          epson-escpr
          samsung-unified-linux-driver
          splix
        ];
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      udev.packages = with pkgs; [
        sane-airscan
        utsushi
      ];
    };

    hardware.sane = {
      enable = true;
      extraBackends = with pkgs; [
        sane-airscan
        epkowa
        utsushi
      ];
    };

    programs.system-config-printer.enable = true;

    users.groups.scanner.members = normal_users;
    users.groups.lp.members = normal_users;
  };
}
