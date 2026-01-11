# sunshine-virtual-display.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.winter.virtual-display;

  edidGenerator = pkgs.callPackage ../../lib/edid.nix {};

  # Fonction pour créer une configuration d'écran virtuel
  mkVirtualDisplay = idx: displayCfg: let
    edidFile = edidGenerator.writeEdid {
      width = displayCfg.width;
      height = displayCfg.height;
      refreshRate = displayCfg.refreshRate;
      enableHdr = displayCfg.enableHdr;
      displayName = displayCfg.displayName;
    };
    edidName = "mx-virtual-display-${toString idx}.bin";
  in {
    inherit edidFile edidName;
    output = displayCfg.videoOutput;
    config = displayCfg;
  };

  # Créer toutes les configurations d'écrans virtuels
  virtualDisplays = lib.imap0 mkVirtualDisplay cfg.displays;

  # Type pour un écran virtuel
  displayType = lib.types.submodule {
    options = {
      videoOutput = lib.mkOption {
        type = lib.types.str;
        description = ''
          The video output to use for this virtual display.
          Find available outputs with:

          for p in /sys/class/drm/*/status; do
            con=''${p%/status};
            echo "''${con#*/card?-}: $(cat $p)";
          done
        '';
        example = "HDMI-A-1";
      };

      width = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = "Virtual display width in pixels";
      };

      height = lib.mkOption {
        type = lib.types.int;
        default = 1080;
        description = "Virtual display height in pixels";
      };

      refreshRate = lib.mkOption {
        type = lib.types.int;
        default = 60;
        description = "Virtual display refresh rate in Hz";
      };

      enableHdr = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable HDR support in virtual display";
      };

      displayName = lib.mkOption {
        type = lib.types.str;
        default = "Virtual Display";
        description = "Display name (max 13 characters)";
      };
    };
  };

in
{
  options.winter.virtual-display = {
    enable = lib.mkEnableOption "virtual display(s) for Sunshine streaming";

    displays = lib.mkOption {
      type = lib.types.listOf displayType;
      default = [];
      description = ''
        List of virtual displays to create.
        Each display can have its own resolution, refresh rate, and settings.
      '';
      example = lib.literalExpression ''
        [
          {
            videoOutput = "HDMI-A-1";
            width = 1920;
            height = 1080;
            refreshRate = 60;
            displayName = "Virtual 1080p";
          }
          {
            videoOutput = "HDMI-A-2";
            width = 2560;
            height = 1440;
            refreshRate = 144;
            displayName = "Virtual 1440p";
          }
        ]
      '';
    };

    physicalOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "DP-1" ];
      description = "Physical display outputs to manage";
      example = [ "DP-1" "DP-2" ];
    };

    useWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use wlr-randr for Wayland instead of xrandr";
    };
  };

  config = lib.mkIf cfg.enable {

    # Générer les firmwares EDID pour tous les écrans virtuels
    hardware.firmware = [
      (pkgs.runCommand "edid-firmware" {} ''
        mkdir -p $out/lib/firmware/edid
        ${lib.concatMapStringsSep "\n" (vd: ''
          cp ${vd.edidFile} $out/lib/firmware/edid/${vd.edidName}
        '') virtualDisplays}
      '')
    ];

    # Add edid path and display output in kernel param
    boot.kernelParams =
      let
        edidList = map (vd: "${vd.output}:edid/${vd.edidName}") virtualDisplays;
        edidParam = "drm.edid_firmware=${builtins.concatStringsSep "," edidList}";
        videoParams = map (vd: "video=${vd.output}:e") virtualDisplays;
      in
        [ edidParam ] ++ videoParams;

    # Add edid file in initframe
    boot.initrd.extraFiles = lib.listToAttrs (map (vd:
      lib.nameValuePair "lib/firmware/edid/${vd.edidName}" vd.edidFile
    ) virtualDisplays);
  };
}
