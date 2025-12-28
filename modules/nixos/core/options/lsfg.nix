{ lib, ... }:
with lib;
{
  options.winter.games.lsfg = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Losseless Scaling (required Lossless scaling app on Steam)";
    };
    steam_library_for_lossless_scaling = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to lossless scaling DLL";
    };
  };
}
