{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.modeling;
in
{
  options.winter.programs.modeling = {
    enable = lib.mkEnableOption "Enable modeling software";
  };

  config = lib.mkIf cfg.enable {
    winter.hardware.gpu.enable-acceleration = true;
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
