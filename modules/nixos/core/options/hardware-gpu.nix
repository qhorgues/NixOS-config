{ lib, ... }:
with lib;
{
  options.mx.hardware.gpu = {
    vendor = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPU constructor (amd, nvidia, intel)";
    };

    enable-computing = mkOption {
      type = types.bool;
      default = false;
      description = "enable gpu computing (cuda, rocm)";
    };

    computing = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "computing (cuda, rocm, intel, cpu)";
    };

    generation = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "GPU génération (blackwell, ada-lovelace, ampere for NVidia; rdna4, rdna3, rdna2 for AMD)";
    };
  };
}
