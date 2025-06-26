{ config, lib, ... }:

{
  options = {
    enableTarsh = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "enable trash support";
    };
    };

  config = lib.mkIf config.enableTarsh {
    environment.sessionVariables.GIO_EXTRA_MODULES = lib.mkForce "${config.services.gvfs.package}/lib/gio/modules";
      environment.variables.GIO_EXTRA_MODULES = lib.mkForce config.environment.sessionVariables.GIO_EXTRA_MODULES;
  };
}
