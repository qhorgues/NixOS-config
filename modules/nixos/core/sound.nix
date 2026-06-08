{ lib, config, ... }:

let
  cfg = config.mx.core.sound;
in
{
  options.mx.core.sound = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sound fonctionnality";
    };
  };

  config = lib.mkIf (!config.mx.mode.server.enable && cfg.enable) {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      # Based on GLF OS configuration
      extraConfig.pipewire = {
        "91-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 256;
          };
        };
        "92-noise-suppression" = {
          "context.modules" = [{
            name = "libpipewire-module-filter-chain";
            flags = [ "nofail" ];
            args = {
              "node.description" = "Noise Canceling Source";
              "media.name" = "Noise Canceling Source";
              "filter.graph" = {
                nodes = [{
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "librnnoise_ladspa";
                  label = "noise_suppressor_stereo";
                  control = { "VAD Threshold (%)" = 50.0; };
                }];
              };
              "capture.props" = {
                "node.name" = "effect_input.rnnoise";
                "node.passive" = true;
                "audio.rate" = 48000;
                "audio.position" = [ "FL" "FR" ];
              };
              "playback.props" = {
                "node.name" = "rnnoise_source";
                "node.description" = "Noise Canceling Source";
                "media.class" = "Audio/Source";
                "audio.rate" = 48000;
                "audio.position" = [ "FL" "FR" ];
              };
            };
          }];
        };
      };
      wireplumber.extraConfig = {
        "10-disable-camera" = {
          "wireplumber.profiles" = {
            main = {
              "monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
  };
}
