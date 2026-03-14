{ pkgs, lib, config, ... }:

let
  cfg = config.mx.hardware.bluetooth;
in
{
  options = {
    mx.hardware.bluetooth.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "enable bluetooth support";
    };
  };

  config = lib.mkIf (!cfg.enable) {
    hardware.bluetooth.enable = lib.mkForce false;
    environment.gnome.excludePackages = with pkgs; [
      gnome-bluetooth
    ];
  };
}
