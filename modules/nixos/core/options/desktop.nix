{ lib, config, ... }:
{
  options.mx.desktop.environment = lib.mkOption {
    type = lib.types.enum [ "none" "gnome" "plasma" "lxqt" ];
    default = "none";
    description = ''
      Desktop environment. "gnome" and "lxqt" configure the DE; "plasma" only
      selects Plasma specific behaviour (main screen detection), the DE itself
      must be enabled by the host.
    '';
  };

  config.warnings = lib.optional
    (config.mx.desktop.environment == "plasma" && !config.services.desktopManager.plasma6.enable)
    ''mx.desktop.environment = "plasma" but services.desktopManager.plasma6.enable is false: this repo provides no Plasma module.'';
}
