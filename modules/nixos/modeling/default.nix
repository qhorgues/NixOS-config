{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.modeling;
in
{
  options.mx.programs.modeling = {
    enable = lib.mkEnableOption "Enable modeling software";
  };

  config = lib.mkIf cfg.enable {
    mx.hardware.gpu.enable-acceleration = true;
    environment.systemPackages = with pkgs; [
      (if cgpu.vendor == "nvidia" then
          blender.override {
            cudaSupport = true;
          }
        else if cgpu.vendor == "amd" then
          blender-hip
        else
          blender)
      bambu-studio
    ];
  };
}
