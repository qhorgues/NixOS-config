{ config, lib, pkgs, ... }:

let
  cgpu = config.mx.hardware.gpu;
  ccpu = config.mx.hardware.cpu;

  intel-legacy = ccpu.generation == "legacy";
  intel-graphics = ccpu.vendor == "intel" || cgpu.vendor == "intel";
  nvidia = cgpu.vendor == "nvidia";
in {

  config = lib .mkIf (!config.mx.mode.server.enable) {
    hardware.graphics = {
      enable = true;

      extraPackages = with pkgs;
        lib.optional intel-graphics
          (if intel-legacy then intel-vaapi-driver else intel-media-driver)
        ++ lib.optional nvidia libva-vdpau-driver
        ++ lib.optional (intel-graphics || nvidia) libvdpau-va-gl;
    };

    environment.sessionVariables = lib.mkMerge [
      (lib.mkIf (cgpu.vendor == "intel") {
        LIBVA_DRIVER_NAME = if intel-legacy then "i965" else "iHD";
      })
      (lib.mkIf nvidia {
        LIBVA_DRIVER_NAME       = "nvidia";
        MOZ_DISABLE_RDD_SANDBOX = "1";  # Firefox VAAPI
      })
    ];
  };
}
