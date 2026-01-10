# sunshine-virtual-display.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.sunshine-virtual-display;

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
      default = false;
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

    # Paramètres du noyau pour tous les écrans
    boot.kernelParams =
      let
        # Liste des paires "OUTPUT:edid/NAME"
        edidList = map (vd: "${vd.output}:edid/${vd.edidName}") virtualDisplays;

        # Une seule option drm.edid_firmware= avec toutes les valeurs séparées par des virgules
        edidParam = "drm.edid_firmware=${builtins.concatStringsSep "," edidList}";

        # video= répété pour chaque écran
        videoParams = map (vd: "video=${vd.output}:e") virtualDisplays;
      in
        [ edidParam ] ++ videoParams;




    # Inclure tous les EDID dans l'initramfs
    boot.initrd.extraFiles = lib.listToAttrs (map (vd:
      lib.nameValuePair "lib/firmware/edid/${vd.edidName}" vd.edidFile
    ) virtualDisplays);

    # Scripts de gestion des displays
    environment.systemPackages =
      let
        # Script pour lister les sorties disponibles
        listOutputsScript = pkgs.writeShellScriptBin "sunshine-list-outputs" ''
          #!/usr/bin/env bash

          echo "=== Sorties vidéo disponibles ==="
          echo ""

          for p in /sys/class/drm/card*/status; do
            if [ -f "$p" ]; then
              con=''${p%/status}
              output=$(basename "$con" | sed 's/^card[0-9]*-//')
              status=$(cat "$p")

              case "$status" in
                "connected")
                  echo "✓ $output - CONNECTÉ (écran physique)"
                  ;;
                "disconnected")
                  echo "○ $output - DISPONIBLE (libre)"
                  ;;
                *)
                  echo "? $output - $status"
                  ;;
              esac
            fi
          done

          echo ""
          echo "=== Configuration actuelle ==="
          ${if cfg.useWayland then
            "${pkgs.wlr-randr}/bin/wlr-randr"
          else
            "${pkgs.xorg.xrandr}/bin/xrandr"
          }
        '';

        # Script pour afficher les infos de configuration
        infoScript = pkgs.writeShellScriptBin "sunshine-display-info" ''
          #!/usr/bin/env bash

          echo "=== Configuration des displays virtuels ==="
          echo ""
          ${lib.concatImapStringsSep "\n" (idx: vd: let
            displayNum = idx - 1;
          in ''
            echo "Display ${toString displayNum}: ${vd.config.displayName}"
            echo "  Sortie: ${vd.output}"
            echo "  Résolution: ${toString vd.config.width}x${toString vd.config.height}"
            echo "  Refresh rate: ${toString vd.config.refreshRate}Hz"
            echo "  HDR: ${if vd.config.enableHdr then "activé" else "désactivé"}"
            echo "  EDID: ${vd.edidName}"
            echo ""
          '') virtualDisplays}

          echo "=== Displays physiques configurés ==="
          ${lib.concatMapStringsSep "\n" (output: ''
            echo "  - ${output}"
          '') cfg.physicalOutputs}
          echo ""

          echo "=== État actuel des displays ==="
          ${if cfg.useWayland then
            "${pkgs.wlr-randr}/bin/wlr-randr"
          else
            "${pkgs.xorg.xrandr}/bin/xrandr"
          }
        '';

        enableVirtualScript = pkgs.writeShellScriptBin "sunshine-start" ''
          #!/usr/bin/env bash

          set -e

          echo "🚀 Activation des displays virtuels pour Sunshine..."
          echo ""

          ${if cfg.useWayland then ''
            # Wayland (wlr-randr)

            # Désactiver les displays physiques
            ${lib.concatMapStringsSep "\n" (output: ''
              echo "Désactivation de ${output}..."
              ${pkgs.wlr-randr}/bin/wlr-randr --output ${output} --off 2>/dev/null || true
            '') cfg.physicalOutputs}

            echo ""

            # Activer les displays virtuels
            ${lib.concatImapStringsSep "\n" (idx: vd: let
              displayNum = idx - 1;
            in ''
              echo "Activation du display ${toString displayNum} sur ${vd.output} (${toString vd.config.width}x${toString vd.config.height}@${toString vd.config.refreshRate}Hz)..."
              ${pkgs.wlr-randr}/bin/wlr-randr \
                --output ${vd.output} \
                --on \
                --mode ${toString vd.config.width}x${toString vd.config.height}@${toString vd.config.refreshRate}Hz 2>/dev/null || \
                echo "⚠️  Échec de l'activation de ${vd.output}"
            '') virtualDisplays}
          '' else ''
            # X11 (xrandr)

            # Désactiver les displays physiques
            ${lib.concatMapStringsSep "\n" (output: ''
              echo "Désactivation de ${output}..."
              ${pkgs.xorg.xrandr}/bin/xrandr --output ${output} --off 2>/dev/null || true
            '') cfg.physicalOutputs}

            echo ""

            # Activer les displays virtuels
            ${lib.concatImapStringsSep "\n" (idx: vd: let
              displayNum = idx - 1;
              isPrimary = idx == 1;
            in ''
              echo "Activation du display ${toString displayNum} sur ${vd.output} (${toString vd.config.width}x${toString vd.config.height}@${toString vd.config.refreshRate}Hz)..."
              ${pkgs.xorg.xrandr}/bin/xrandr \
                --output ${vd.output} \
                --mode ${toString vd.config.width}x${toString vd.config.height} \
                --rate ${toString vd.config.refreshRate} \
                ${lib.optionalString isPrimary "--primary"} 2>/dev/null || \
                echo "⚠️  Échec de l'activation de ${vd.output}"
            '') virtualDisplays}
          ''}

          echo ""
          echo "✅ Displays virtuels activés"
        '';

        disableVirtualScript = pkgs.writeShellScriptBin "sunshine-stop" ''
          #!/usr/bin/env bash

          set -e

          echo "🔄 Restauration des displays physiques..."
          echo ""

          ${if cfg.useWayland then ''
            # Wayland

            # Désactiver tous les displays virtuels
            ${lib.concatImapStringsSep "\n" (idx: vd: let
              displayNum = idx - 1;
            in ''
              echo "Désactivation du display ${toString displayNum} (${vd.output})..."
              ${pkgs.wlr-randr}/bin/wlr-randr --output ${vd.output} --off 2>/dev/null || true
            '') virtualDisplays}

            echo ""

            # Réactiver les displays physiques
            ${lib.concatMapStringsSep "\n" (output: ''
              echo "Réactivation de ${output}..."
              ${pkgs.wlr-randr}/bin/wlr-randr --output ${output} --on 2>/dev/null || true
            '') cfg.physicalOutputs}
          '' else ''
            # X11

            # Désactiver tous les displays virtuels
            ${lib.concatImapStringsSep "\n" (idx: vd: let
              displayNum = idx - 1;
            in ''
              echo "Désactivation du display ${toString displayNum} (${vd.output})..."
              ${pkgs.xorg.xrandr}/bin/xrandr --output ${vd.output} --off 2>/dev/null || true
            '') virtualDisplays}

            echo ""

            # Réactiver les displays physiques
            ${lib.concatMapStringsSep "\n" (output: ''
              echo "Réactivation de ${output}..."
              ${pkgs.xorg.xrandr}/bin/xrandr --output ${output} --auto 2>/dev/null || true
            '') cfg.physicalOutputs}

            # Définir le premier comme primary
            echo "Configuration du display principal..."
            ${pkgs.xorg.xrandr}/bin/xrandr --output ${lib.head cfg.physicalOutputs} --primary 2>/dev/null || true
          ''}

          echo ""
          echo "✅ Displays physiques restaurés"
        '';

      in [
        enableVirtualScript
        disableVirtualScript
        infoScript
        listOutputsScript
      ] ++ lib.optional cfg.useWayland pkgs.wlr-randr;
  };
}
