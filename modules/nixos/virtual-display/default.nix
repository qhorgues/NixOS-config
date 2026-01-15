# sunshine-virtual-display.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.winter.virtual-display;

  edidGenerator = pkgs.callPackage ./edid.nix {};

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
  videoOutputs = lib.map (display: display.videoOutput) cfg.displays;

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

  listVirtualDisplays = pkgs.writeShellScriptBin "winter-list-virtual-displays" ''
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

  list-available-display-interface = pkgs.writeShellScriptBin "winter-list-available-display-interface" ''
    #!${pkgs.bash}/bin/bash

    VIRTUAL_OUTPUTS=(${lib.concatStringsSep " " (map (o: ''"${o}"'') videoOutputs)})

    for p in /sys/class/drm/*/status; do
        con=''${p%/status}
        name=''${con#*/card?-}
        status=$(cat $p)

        # Vérifier si l'output est dans la liste des virtuels
        is_virtual=false
        for vo in "''${VIRTUAL_OUTPUTS[@]}"; do
        if [ "$name" = "$vo" ]; then
            is_virtual=true
            break
        fi
        done

        # Afficher avec le bon symbole
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

  activateVirtualDisplay = pkgs.writeShellScriptBin "activate-virtual-display" ''
      #!${pkgs.bash}/bin/bash
      set -e

      DEFAULT_DISPLAYS=(
        ${lib.concatMapStringsSep "\n      " (vd:
          ''"${vd.output}:${toString vd.config.width}x${toString vd.config.height}@${toString vd.config.refreshRate}"''
        ) virtualDisplays}
      )

      show_usage() {
        echo "Usage: $0 <output> [width] [height] [refresh_rate]"
        echo ""
        echo "Arguments:"
        echo "  output        Output name (e.g., HDMI-A-1)"
        echo "  width         Width in pixels (optional)"
        echo "  height        Height in pixels (optional)"
        echo "  refresh_rate  Refresh rate in Hz (optional)"
        echo ""
        echo "Available virtual displays with defaults:"
        for disp in "''${DEFAULT_DISPLAYS[@]}"; do
          echo "  $disp"
        done
        echo ""
        echo "Example:"
        echo "  $0 HDMI-A-1              # Use default resolution and refresh rate"
        echo "  $0 HDMI-A-1 1920 1080    # Use 1920x1080 with default refresh rate"
        echo "  $0 HDMI-A-1 1920 1080 60 # Use 1920x1080@60Hz"
        exit 1
      }

      if [ $# -lt 1 ]; then
        show_usage
      fi

      OUTPUT="$1"
      WIDTH=""
      HEIGHT=""
      REFRESH=""

      for disp in "''${DEFAULT_DISPLAYS[@]}"; do
        if [[ "$disp" == "$OUTPUT:"* ]]; then
          defaults="''${disp#*:}"
          WIDTH=$(echo "$defaults" | cut -d'x' -f1)
          HEIGHT=$(echo "$defaults" | cut -d'x' -f2 | cut -d'@' -f1)
          REFRESH=$(echo "$defaults" | cut -d'@' -f2)
          break
        fi
      done

      WIDTH=''${2:-$WIDTH}
      HEIGHT=''${3:-$HEIGHT}
      REFRESH=''${4:-$REFRESH}

      if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ] || [ -z "$REFRESH" ]; then
        echo "Error: Output '$OUTPUT' not found in virtual displays configuration"
        echo "Please provide width, height, and refresh rate manually."
        echo ""
        show_usage
      fi

      if ! command -v gdbus &> /dev/null; then
        echo "Error: gdbus command not found"
        exit 1
      fi

      STATE=$(gdbus call --session \
        --dest org.gnome.Mutter.DisplayConfig \
        --object-path /org/gnome/Mutter/DisplayConfig \
        --method org.gnome.Mutter.DisplayConfig.GetCurrentState)

      CURRENT_SERIAL=$(echo "$STATE" | grep -oP 'uint32 \K[0-9]+' | head -1)

      MODE_ID=$(echo "$STATE" | grep -oP "'\K[^']*?''${WIDTH}x''${HEIGHT}[^']*" | head -1)

      if [ -z "$MODE_ID" ]; then
        echo "Warning: No exact mode found for ''${WIDTH}x''${HEIGHT}@''${REFRESH}"
        echo "Trying to find closest match..."
        MODE_ID=$(echo "$STATE" | grep -oP "'\K[^']*?''${WIDTH}x''${HEIGHT}[^']*" | head -1)
      fi

      if [ -z "$MODE_ID" ]; then
        echo "Error: Could not find a valid mode for the specified resolution"
        echo "Available modes for $OUTPUT:"
        echo "$STATE" | grep -oP "'[0-9]+x[0-9]+@[^']*" | sort -u
        exit 1
      fi

      SAVED_CONFIG="/tmp/mx-mutter-display-config-$.txt"
      echo "$STATE" > "$SAVED_CONFIG"

      gdbus call --session \
        --dest org.gnome.Mutter.DisplayConfig \
        --object-path /org/gnome/Mutter/DisplayConfig \
        --method org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig \
        "$CURRENT_SERIAL" \
        1 \
        "[(0, 0, 1.0, 0, true, [(\"$OUTPUT\", \"$MODE_ID\", {})])]" \
        {}

      APPLY_EXIT=$?

      if [ $APPLY_EXIT -ne 0 ]; then
        echo "Error: Failed to apply virtual display configuration"
        rm -f "$SAVED_CONFIG"
        exit 1
      fi
    '';

in
{
  options.winter.virtual-display = {
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
  };

  config = {

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

    environment.systemPackages = [ listVirtualDisplays list-available-display-interface
      activateVirtualDisplay];
  };
}
