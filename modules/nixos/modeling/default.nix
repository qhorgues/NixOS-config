{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.modeling;
  cgpu = config.mx.hardware.gpu;
in
{
  options.mx.programs.modeling = {
    enable = lib.mkEnableOption "Enable modeling software";
  };

  config = lib.mkIf cfg.enable {
    mx.hardware.gpu.enable-computing = true;
    environment.systemPackages = with pkgs; [
      (if cgpu.vendor == "nvidia" then
          blender.override {
            cudaSupport = true;
          }
        else if cgpu.vendor == "amd" then
          pkgsRocm.blender
        else
          blender)
      bambu-studio
    ];
  };
}
