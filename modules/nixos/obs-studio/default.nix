{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.obs-studio;
  cgpu = config.winter.hardware.gpu;
in
{
  options.winter.programs.obs-studio = {
    enable = lib.mkEnableOption "Enable OBS Studio";
  };

  config = lib.mkIf cfg.enable {
    winter.hardware.gpu.enable-acceleration = true;
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      package = (
        if cgpu.vendor != "nvidia" then
          pkgs.obs-studio
        else
          pkgs.obs-studio.override { cudaSupport = true; }
      );
      plugins = with pkgs.obs-studio-plugins; [
        obs-move-transition
      ] ++ lib.optional config.winter.programs.games.enable pkgs.obs-studio-plugins.obs-vkcapture;
    };
  };

}
