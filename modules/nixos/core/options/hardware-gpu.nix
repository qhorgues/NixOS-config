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
  };
}
