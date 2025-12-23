{ lib, ... }:

{
  options.winter.hardware.acceleration = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "cuda" "rocm" ]);
    default = null;
    description = ''
      material acceleration
      null = CPU, "cuda" = NVIDIA CUDA, "rocm" = AMD ROCm.
    '';
  };
}
