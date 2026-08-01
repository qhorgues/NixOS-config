{ lib, ... }:
with lib;
{
  options.mx.hardware.cpu = {
    vendor = mkOption {
      type = types.nullOr (types.enum [ "intel" "amd" ]);
      default = null;
      description = "CPU constructor (intel, amd)";
    };

    generation = mkOption {
      type = types.nullOr (types.enum [ "modern" "legacy" ]);
      default = null;
      description = ''
        Intel iGPU era: "modern" for Gen8+/Broadwell and newer (iHD driver),
        "legacy" for older iGPUs (i965 driver). Ignored on AMD CPUs.
        null is treated as "modern".
      '';
    };
  };
}
