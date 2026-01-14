{ config, pkgs, lib, ... }:

let
  cfg = config.winter.hardware.powersave;
in
{
  options.winter.hardware.powersave = {
    enable = lib.mkEnableOption "Auto enable energy savings";
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Unplug
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

      # Plug
      SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
    '';
  };
}
