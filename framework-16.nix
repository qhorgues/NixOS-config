{ pkgs, ... }:

let
  nixos-hardware = builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
in
{
  imports = [
    (import "${nixos-hardware}/framework/16-inch/7040-amd")
  ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/mnt/Games" =
  { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  environment.systemPackages = with pkgs; [
    gnome-randr
  ];
  services.udev.extraRules = ''
    # Unplug
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"



    # Plug
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"

  '';

  /*
  RUN+="${pkgs.lib.getExe (pkgs.writeShellScriptBin "powersave"
  ''
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
    ${pkgs.su}/bin/su - quentin -c "${pkgs.dbus}/bin/dbus-launch `${pkgs.gnome-randr}/bin/gnome-randr modify 'eDP-1' --mode 2560x1600@60.002`"
  '')}"

  "${pkgs.lib.getExe (pkgs.writeShellScriptBin "performance"
  ''
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
    ${pkgs.su}/bin/su - quentin -c "${pkgs.dbus}/bin/dbus-launch `${pkgs.gnome-randr}/bin/gnome-randr modify 'eDP-1' --mode 2560x1600@165.000`"
  '')}"
  */
}
