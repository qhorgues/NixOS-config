{ lib, ... }:
with lib;
{
  options.winter.hardware.gpu.vendor = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "GPU constructor (amdgpu, nvidia, intel)";
  };

  options.winter.hardware.gpu.enable-acceleration = mkOption {
    type = types.bool;
    default = false;
    description = "enable gpu acceleration (cuda, rocm)";
  };

  options.winter.hardware.gpu.acceleration = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Acceleration (cuda, rocm)";
  };
}
