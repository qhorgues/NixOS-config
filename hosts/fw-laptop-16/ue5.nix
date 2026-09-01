# ue5.nix
#
# NixOS module for Unreal Engine 5 via a dedicated distrobox container.
# Uses distrobox-app.nix for all generic install/manage/uninstall logic.

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.distrobox-ue5;

  distroboxApp = import ./distrobox-app.nix { inherit pkgs lib; };

  ue5Icon = pkgs.writeText "ue5-icon.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
      <rect width="128" height="128" rx="16" fill="#1a1a1a"/>
      <text x="64" y="90" font-family="sans-serif" font-size="80"
            font-weight="bold" text-anchor="middle" fill="white">U</text>
    </svg>
  '';

  app = distroboxApp.mkApp {
    name           = "ue5";
    displayName    = "Unreal Engine 5";
    containerImage = cfg.containerImage;  # full image name, e.g. "ubuntu:22.04"
    installDir     = cfg.ue5InstallDir;
    environment    = "DRI_PRIME=0";
    binaryRelPath  = "Engine/Binaries/Linux/UnrealEditor";
    icon           = ue5Icon;
    nvidia         = cfg.nvidia;

    additionalContainerPkgs = cfg.additionalPackages;

    # Validate that the zip looks like a UE5 archive
    zipValidator = "Engine/";

    # After extraction, prefer the real UE5 icon over the placeholder SVG
    iconPostInstall = "$INSTALL_DIR/Engine/Content/Editor/Slate/Icons/UE_Logo_icon.png";

    # ── Install steps ──────────────────────────────────────────────────────
    # Each step runs on the host. $CONTAINER, $INSTALL_DIR and $ZIP_PATH
    # are exported and available in every script block.
    installSteps = [
      {
        label  = "Extracting the Unreal Engine 5 archive…";
        script = ''
          mkdir -p "$INSTALL_DIR"
          ${pkgs.unzip}/bin/unzip -o "$ZIP_PATH" -d "$INSTALL_DIR"

          # Some Epic archives wrap everything in a top-level subfolder
          # (e.g. UnrealEngine-5.x.x/). Detect and flatten if needed.
          FOUND=$(find "$INSTALL_DIR" -maxdepth 2 -name "UnrealEditor" -type f 2>/dev/null | head -1)
          if [ -z "$FOUND" ]; then
            INNER=$(find "$INSTALL_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | head -1)
            if [ -n "$INNER" ] && [ -d "$INNER/Engine" ]; then
              shopt -s dotglob
              mv "$INNER"/* "$INSTALL_DIR"/
              rmdir "$INNER"
            fi
          fi
        '';
      }
      {
        label  = "Installing system dependencies in the container…";
        script = ''
          ${pkgs.distrobox}/bin/distrobox enter "$CONTAINER" -- bash -s << 'INNER'
            set -euo pipefail
            export DEBIAN_FRONTEND=noninteractive
            sudo apt-get update -y -qq
            sudo apt-get install -y -qq \
              libglu1-mesa libgl1-mesa-dri \
              libvulkan1 libvulkan-dev vulkan-tools vulkan-validationlayers \
              mesa-vulkan-drivers libgl1-mesa-dri \
              libx11-6 libxcursor1 libxrandr2 libxinerama1 libxi6 \
              libxext6 libxfixes3 libxss1 libxcb1 libxcomposite1 \
              libxdamage1 libxkbcommon0 \
              libpulse0 libasound2 libudev1 libsdl2-2.0-0 \
              libfontconfig1 libfreetype6 libnss3 libnspr4 \
              libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
              libdbus-1-3 libexpat1 libpango-1.0-0 libcairo2 libgbm1 libegl1 \
              mono-runtime libmono-system-core4.0-cil \
              dotnet-runtime-6.0 libicu70 \
              libnss3 libasound2t64 \
              openssl ca-certificates libssl3 patchelf
INNER
        '';
      }
    ];

    # ── UI strings ─────────────────────────────────────────────────────────
    ui = {
      welcomeText = "<b>Welcome to the Unreal Engine 5 installer</b>\n\nPlease select the <b>.zip</b> archive downloaded from the Epic Games website (Linux prebuilt version).\n\n<small>Destination: <tt>${cfg.ue5InstallDir}</tt></small>";
      selectZipTitle       = "Select the Unreal Engine 5 archive (.zip)";
      doneText             = "<b>Installation complete!</b>\n\nUnreal Engine 5 is ready.\nThe editor will now start.";
      errorBinaryNotFound  = "Extraction failed or the archive does not contain a prebuilt Linux editor.\n\nPlease download the <b>Linux</b> version from the Epic Games website.";
      uninstallConfirmText = "This will permanently remove:\n\n  • Unreal Engine 5 files in <tt>${cfg.ue5InstallDir}</tt>\n  • The dedicated container <b>distrobox-app-ue5</b>\n\nAre you sure?";
      uninstalledText      = "<b>Unreal Engine 5 has been uninstalled.</b>\n\nThe container <b>distrobox-app-ue5</b> and all files in\n<tt>${cfg.ue5InstallDir}</tt> have been removed.\n\nClick the icon again to reinstall.";
    };

    # ── .desktop metadata ──────────────────────────────────────────────────
    desktop = {
      genericName = "Game Engine";
      comment     = "Unreal Engine 5 Editor";
      categories  = "Development;IDE;GameDevelopment;";
      mimeType    = "application/x-ue4project;";
      wmClass     = "UnrealEditor";
      keywords    = "unreal;ue5;gamedev;epic;";
    };
  };

in
{
  options.programs.distrobox-ue5 = {
    enable = lib.mkEnableOption "Unreal Engine 5 via a dedicated Distrobox container";


    containerImage = lib.mkOption {
      type        = lib.types.str;
      default     = "ubuntu:26.04";
      description = ''
        Full OCI image name used to create the container.
        Ubuntu 22.04 LTS is recommended for UE5 compatibility.
        Any image available to Podman/Docker can be used.
      '';
      example = "ubuntu:26.04";
    };

    nvidia = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
      description = ''
        Pass --nvidia to distrobox at container creation.
        Only enable this if you have an Nvidia GPU and
        nvidia-container-toolkit configured on your system.
      '';
    };

    ue5InstallDir = lib.mkOption {
      type        = lib.types.str;
      default     = "$HOME/.local/share/ue5";
      description = "Directory where the UE5 archive will be extracted.";
      example     = "$HOME/games/UnrealEngine5";
    };

    additionalPackages = lib.mkOption {
      type        = lib.types.listOf lib.types.str;
      default     = [];
      description = "Extra Ubuntu packages passed to distrobox at container creation.";
      example     = [ "htop" "neovim" ];
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      distrobox
      podman
    ] ++ app.packages;

    # Podman rootless — recommended with distrobox on NixOS
    virtualisation.podman = {
      enable       = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };

    # nvidia-container-toolkit is only activated when the user opts in via
    # programs.distrobox-ue5.nvidia = true, and only when the Nvidia driver
    # modesetting is already enabled on this machine.
    hardware.nvidia-container-toolkit.enable = lib.mkIf cfg.nvidia
      (lib.mkDefault config.hardware.nvidia.modesetting.enable);

    # Install the initial .desktop at first graphical login.
    # The launcher overwrites it with the definitive version
    # (real icon, no "click to install" suffix) once UE5 is set up.
    systemd.user.services.distrobox-ue5-desktop = {
      description = "Install initial Unreal Engine 5 .desktop entry";
      wantedBy    = [ "graphical-session.target" ];
      after       = [ "graphical-session.target" ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ue5-install-desktop" ''
          APPS="$HOME/.local/share/applications"
          DEST="$APPS/ue5.desktop"
          mkdir -p "$APPS"
          # Don't overwrite a .desktop already written by the launcher
          if [ ! -f "$DEST" ]; then
            cp ${app.initialDesktop} "$DEST"
            chmod 644 "$DEST"
            ${pkgs.desktop-file-utils}/bin/update-desktop-database "$APPS" 2>/dev/null || true
          fi
        '';
      };
    };
  };
}
