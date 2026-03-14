{ lib, ... }:
with lib;
{
  options.mx.hardware.framework-fan-ctrl.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable fan control for framework";
  };
}
