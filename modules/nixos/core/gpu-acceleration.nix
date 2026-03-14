{ config, pkgs, lib, ...}:
let
  cgpu = config.mx.hardware.gpu;
in
{
  config = lib.mkMerge [
    (
      lib.mkIf (cgpu.vendor == "amd" && cgpu.enable-acceleration) {
        systemd.tmpfiles.rules =
        let
          rocmEnv = pkgs.symlinkJoin {
            name = "rocm-combined";
            paths = with pkgs.rocmPackages; [
              rocblas
              hipblas
              clr
            ];
          };
        in [
          "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
        ];
        hardware.amdgpu.opencl.enable = true;
        hardware.graphics = {
          extraPackages = with pkgs; [
            mesa.opencl
          ];
        };
        environment.variables = {
          ROC_ENABLE_PRE_VEGA = "1";
          RUSTICL_ENABLE      = "radeonsi";
        };
      }
    )
    (
      lib.mkIf (cgpu.vendor == "intel" && cgpu.enable-acceleration) {
        hardware.graphics = {
          extraPackages = with pkgs; [
            intel-compute-runtime
          ];
        };
      }
    )
  ];
}
