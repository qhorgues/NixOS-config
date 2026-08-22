{ config, lib, ... }:
{
  config = lib.mkIf (!config.mx.mode.server.enable) {
    # Manipulate storage device
    services.udisks2 = {
      enable = true;
    };
  };
}
