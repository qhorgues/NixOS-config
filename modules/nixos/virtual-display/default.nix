{ config, lib, pkgs, ... }:

let
  cfg = config.mx.virtual-display;

  edidGenerator = pkgs.callPackage ../../../lib/edid.nix {};

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

  virtualDisplays = lib.imap0 mkVirtualDisplay cfg.displays;
  videoOutputs = lib.map (display: display.videoOutput) cfg.displays;

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

  listVirtualDisplays = pkgs.writeShellScriptBin "mx-list-virtual-displays" ''
      #!${pkgs.bash}/bin/bash

      ${lib.concatMapStringsSep "\n" (vd: let
        idx = lib.findFirst (i: (lib.elemAt virtualDisplays i).output == vd.output) 0 (lib.range 0 ((lib.length virtualDisplays) - 1));
      in ''
        echo "Display #${toString (idx + 1)}"
        echo "  Name:         ${vd.config.displayName}"
        echo "  Output:       ${vd.output}"
        echo "  Resolution:   ${toString vd.config.width}x${toString vd.config.height}"
        echo "  Refresh Rate: ${toString vd.config.refreshRate}Hz"
        echo "  HDR:          ${if vd.config.enableHdr then "Enabled" else "Disabled"}"
        echo "  EDID File:    ${vd.edidName}"
        echo ""
      '') virtualDisplays}

    '';

  list-available-display-interface = pkgs.writeShellScriptBin "mx-list-available-display-interface" ''
    #!${pkgs.bash}/bin/bash

    VIRTUAL_OUTPUTS=(${lib.concatStringsSep " " (map (o: ''"${o}"'') videoOutputs)})

    for p in /sys/class/drm/*/status; do
        con=''${p%/status}
        name=''${con#*/card?-}
        status=$(cat $p)

        is_virtual=false
        for vo in "''${VIRTUAL_OUTPUTS[@]}"; do
        if [ "$name" = "$vo" ]; then
            is_virtual=true
            break
        fi
        done

        if [ "$status" = "connected" ] && [ "$is_virtual" = true ]; then
        echo "$name (connected + virtual)"
        elif [ "$status" = "connected" ]; then
        echo "$name (connected)"
        elif [ "$is_virtual" = true ]; then
        echo "$name (virtual, not connected)"
        else
        echo -e "$name (disconnected) \e[1;32mAvailable\e[0m"
        fi
    done
  '';

  displaySwitch = pkgs.callPackage ../../../lib/display-switch.nix { displays = cfg.displays; };

  hasDisplays = virtualDisplays != [];

  selected = if cfg.default == null then lib.head virtualDisplays
    else lib.findFirst (vd: vd.output == cfg.default) (lib.head virtualDisplays) virtualDisplays;

  virtualDisplayOn = pkgs.writeShellScriptBin "virtual-display-on" ''
    exec ${displaySwitch.activate}/bin/activate-virtual-display \
      ${selected.output} ${toString selected.config.width} \
      ${toString selected.config.height} ${toString selected.config.refreshRate} "$@"
  '';
  virtualDisplayOff = pkgs.writeShellScriptBin "virtual-display-off" ''
    exec ${displaySwitch.restore}/bin/restore-display "$@"
  '';

in
{
  options.mx.virtual-display = {
    enable = lib.mkEnableOption "virtual displays with Mutter switch/restore scripts";

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

    useWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use wlr-randr for Wayland instead of xrandr";
    };

    default = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Output used by the `virtual-display-on` command and the Sunshine app.
        null selects the first configured display.
      '';
      example = "DP-1";
    };

    sunshine = {
      enable = lib.mkEnableOption "a Sunshine app that streams this virtual display";

      appName = lib.mkOption {
        type = lib.types.str;
        default = "Bureau virtuel";
        description = "Name of the generated Sunshine application.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    hardware.firmware = [
      (pkgs.runCommand "edid-firmware" {} ''
        mkdir -p $out/lib/firmware/edid
        ${lib.concatMapStringsSep "\n" (vd: ''
          cp ${vd.edidFile} $out/lib/firmware/edid/${vd.edidName}
        '') virtualDisplays}
      '')
    ];

    boot.kernelParams =
      let
        edidList = map (vd: "${vd.output}:edid/${vd.edidName}") virtualDisplays;
        edidParam = "drm.edid_firmware=${builtins.concatStringsSep "," edidList}";
        videoParams = map (vd: "video=${vd.output}:e") virtualDisplays;
      in
        [ edidParam ] ++ videoParams;

    boot.initrd.extraFiles = lib.listToAttrs (map (vd:
      lib.nameValuePair "lib/firmware/edid/${vd.edidName}" vd.edidFile
    ) virtualDisplays);

    environment.systemPackages = [ listVirtualDisplays list-available-display-interface
      displaySwitch.activate displaySwitch.restore ]
      ++ lib.optionals hasDisplays [ virtualDisplayOn virtualDisplayOff ];

    services.sunshine.applications.apps = lib.mkIf cfg.sunshine.enable [{
      name = cfg.sunshine.appName;
      prep-cmd = [{
        do = "${virtualDisplayOn}/bin/virtual-display-on";
        undo = "${virtualDisplayOff}/bin/virtual-display-off";
      }];
    }];

    assertions = lib.optionals cfg.sunshine.enable [
      {
        assertion = hasDisplays;
        message = "mx.virtual-display.sunshine.enable needs an entry in mx.virtual-display.displays.";
      }
      {
        assertion = config.services.sunshine.enable;
        message = "mx.virtual-display.sunshine.enable needs Sunshine (mx.services.remote-desktop.enable).";
      }
    ];
  };
}
