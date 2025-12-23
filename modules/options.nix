{ lib, ... }:
with lib;
{
  options.winter.hardware.gpu = {
    vendor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPU constructor (amdgpu, nvidia, intel)";
    };

    enable-acceleration = mkOption {
      type = types.bool;
      default = false;
      description = "enable gpu acceleration (cuda, rocm)";
    };

    acceleration = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Acceleration (cuda, rocm)";
    };

    generation = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPU génération (blackwell, ada-lovelace, ampere for NVidia; rdna4, rdna3, rdna2 for AMD)";
    };

    frame-generation.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Use to enable frame gen on modern GPU";
    };
  };

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

  options.winter.hardware.framework-fan-ctrl.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Enable fan control for framework";
  };
}
