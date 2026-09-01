# distrobox-app.nix
#
# Generic library: mkApp creates a Zenity + distrobox launcher for any
# application installed from a .zip archive.
#
# The launcher is always present (before and after install) and doubles as
# a management UI: launch, uninstall, reinstall.
# Each app gets its own dedicated distrobox container.
#
# Returns: { launchScript, enterScript, initialDesktop, packages }

{ pkgs, lib }:

let
  # Generates the bash block for one install step
  mkStepScript = { label, script }: ''
    echo "--- ${label}"
    (
      ${script}
    ) 2>&1 | ${pkgs.zenity}/bin/zenity --progress \
        --title="$_DISPLAY_NAME" \
        --text=${lib.escapeShellArg label} \
        --pulsate --auto-close --no-cancel --width=500 2>/dev/null || true
  '';

in
{
  # ─────────────────────────────────────────────────────────────────────────
  # mkApp
  #
  # Required parameters:
  #   name              str       short identifier (e.g. "ue5")
  #   displayName       str       name shown in popups (e.g. "Unreal Engine 5")
    #   containerImage    str       full OCI image name, e.g. "ubuntu:22.04"
  #                               or "registry.fedoraproject.org/fedora:39"
  #   installDir        str       installation directory, may contain $HOME
  #   binaryRelPath     str       path to the executable relative to installDir
  #   installSteps      list of { label: str, script: str }
  #                               steps run sequentially on first launch;
  #                               $INSTALL_DIR, $CONTAINER, $ZIP_PATH are exported
  #
  # Optional parameters:
  #   nvidia                    false   pass --nvidia to distrobox create
  #   init                      false   pass --init to distrobox create (only for
  #                                     images that ship an init system)
  #   additionalContainerPkgs   []      packages passed to --additional-packages
  #   icon                      null    pkgs.writeText SVG, or null for fallback
  #   zipValidator              null    grep pattern in `unzip -l` to validate zip
  #   iconPostInstall           null    bash path (may use $INSTALL_DIR) to the
  #                                     icon extracted from the archive
  #   ui.welcomeText            str     Pango text for the welcome popup
  #   ui.selectZipTitle         str     file-chooser title
  #   ui.doneText               str     text shown after successful install
  #   ui.errorBinaryNotFound    str     message when binary is missing after install
  #   ui.uninstallConfirmText   str     confirmation text before uninstall
  #   ui.uninstalledText        str     text shown after successful uninstall
  #   desktop.genericName       str
  #   desktop.comment           str
  #   desktop.categories        str
  #   desktop.mimeType          str
  #   desktop.wmClass           str
  #   desktop.keywords          str
  # ─────────────────────────────────────────────────────────────────────────
  mkApp =
    { name
    , displayName
    , containerImage
    , installDir
    , binaryRelPath
    , installSteps
    , environment             ? ""
    , nvidia                  ? false
    , init                    ? false
    , additionalContainerPkgs ? []
    , icon                    ? null
    , zipValidator            ? null
    , iconPostInstall         ? null
    , ui                      ? {}
    , desktop                 ? {}
    }:

    let
      # The container name is derived solely from `name` to guarantee uniqueness
      # per app and avoid collisions with other distrobox containers.
      # Users never set this directly — they control it via `name`.
      safeContainerName = "distrobox-app-${name}";

      # ── UI defaults ────────────────────────────────────────────────────────
      ui' = {
        welcomeText           = "<b>Welcome to the ${displayName} installer</b>\n\nSelect the <b>.zip</b> archive to install.\n\n<small>Destination: <tt>${installDir}</tt></small>";
        selectZipTitle        = "Select the ${displayName} archive (.zip)";
        doneText              = "<b>Installation complete!</b>\n\n${displayName} is ready.";
        errorBinaryNotFound   = "Installation failed.\nBinary not found after install.";
        uninstallConfirmText  = "This will remove:\n\n  • The <b>${displayName}</b> files in <tt>${installDir}</tt>\n  • The dedicated container <b>${safeContainerName}</b>\n\nAre you sure?";
        uninstalledText       = "<b>${displayName} has been uninstalled.</b>\n\nThe container <b>${safeContainerName}</b> and all files in\n<tt>${installDir}</tt> have been removed.";
      } // ui;

      # ── Desktop defaults ───────────────────────────────────────────────────
      desktop' = {
        genericName = displayName;
        comment     = displayName;
        categories  = "Application;";
        mimeType    = "";
        wmClass     = "";
        keywords    = "";
      } // desktop;

      # ── Icon ──────────────────────────────────────────────────────────────
      fallbackIcon = pkgs.writeText "${name}-icon.svg" ''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
          <rect width="128" height="128" rx="12" fill="#222"/>
          <text x="64" y="88" font-family="monospace" font-size="64"
                font-weight="bold" text-anchor="middle" fill="#fff">▶</text>
        </svg>
      '';
      resolvedIcon = if icon != null then icon else fallbackIcon;

      # ── Install steps script ───────────────────────────────────────────────
      stepsScript = lib.concatMapStrings mkStepScript installSteps;

      # ── Optional zip validation ────────────────────────────────────────────
      zipValidationScript = lib.optionalString (zipValidator != null) ''
        if ! ${pkgs.unzip}/bin/unzip -l "$ZIP_PATH" 2>/dev/null \
            | ${pkgs.gnugrep}/bin/grep -q ${lib.escapeShellArg zipValidator}; then
          ${pkgs.zenity}/bin/zenity --question \
            --title="$_DISPLAY_NAME" \
            --text="This file does not look like a standard ${displayName} archive.\n\nContinue anyway?" \
            --width=460 2>/dev/null || exit 0
        fi
      '';

      # ── Optional post-install icon swap ───────────────────────────────────
      iconPostInstallScript = lib.optionalString (iconPostInstall != null) ''
        _POST_ICON="${iconPostInstall}"
        [ -f "$_POST_ICON" ] && _ICON="$_POST_ICON"
      '';

      # ── Optional desktop fields ────────────────────────────────────────────
      desktopOptionalFields =
          lib.optionalString (desktop'.wmClass  != "") "StartupWMClass=${desktop'.wmClass}\n"
        + lib.optionalString (desktop'.mimeType != "") "MimeType=${desktop'.mimeType}\n"
        + lib.optionalString (desktop'.keywords != "") "Keywords=${desktop'.keywords}\n";

      # ── distrobox create flags ─────────────────────────────────────────────
      # --nvidia is only passed when explicitly requested; the flag will fail
      # on machines without an Nvidia GPU or the nvidia-container-toolkit.
      distroboxCreateFlags =
          "--name \"$CONTAINER\""
        + " --image \"${containerImage}\""
        + lib.optionalString nvidia " --nvidia"
        + lib.optionalString init   " --init"
        + lib.optionalString
            (additionalContainerPkgs != [])
            " --additional-packages \"${lib.concatStringsSep " " additionalContainerPkgs}\"";

      # ── Shared env block ───────────────────────────────────────────────────
      sharedEnv = ''
        export CONTAINER="${safeContainerName}"
        export INSTALL_DIR="${installDir}"
        export BINARY="$INSTALL_DIR/${binaryRelPath}"
        export SENTINEL="$INSTALL_DIR/.${name}_installed"
        export ZIP_PATH=""

        _DISPLAY_NAME="${displayName}"
        _ICON="${resolvedIcon}"
        _DESKTOP_FILE="$HOME/.local/share/applications/${name}.desktop"
      '';

      # ── Shared zenity helpers ──────────────────────────────────────────────
      sharedHelpers = ''
        zinfo()  { ${pkgs.zenity}/bin/zenity --info     --title="$_DISPLAY_NAME" --text="$1" --width=460 2>/dev/null || true; }
        zerror() { ${pkgs.zenity}/bin/zenity --error    --title="$_DISPLAY_NAME — Error"  --text="$1" --width=460 2>/dev/null || true; }
        zask()   { ${pkgs.zenity}/bin/zenity --question --title="$_DISPLAY_NAME" --text="$1" --width=460 2>/dev/null; }
        zpulse() {
          local title="$1" msg="$2"; shift 2
          "$@" 2>&1 | ${pkgs.zenity}/bin/zenity --progress \
            --title="$title" --text="$msg" \
            --pulsate --auto-close --no-cancel --width=500 2>/dev/null || true
        }
      '';

      # ── Install procedure ──────────────────────────────────────────────────
      installProcedure = ''
        # Sanity check: podman must be reachable before anything else
        if ! ${pkgs.podman}/bin/podman info >/dev/null 2>&1; then
          zerror "Podman is not available or not running.\nMake sure virtualisation.podman.enable = true in your NixOS configuration."
          exit 1
        fi

        # Create the dedicated container if it does not exist yet
        # podman container exists returns 0 if the container exists (exact name match)
        if ! ${pkgs.podman}/bin/podman container exists "$CONTAINER" 2>/dev/null; then

          _IMAGE="${containerImage}"
          _RC_FILE=$(mktemp)

          # ── Step 1: pull the image — blocking with pulsed bar ──────────────
          # Exit code is captured via a tempfile because the pipe to zenity
          # runs in a subshell where $PIPESTATUS is unavailable.
          # zenity --no-cancel keeps the bar non-dismissable, ensuring the
          # step is truly blocking from the user's perspective.
          (
            ${pkgs.podman}/bin/podman pull "$_IMAGE" 2>&1
            echo $? > "$_RC_FILE"
          ) | ${pkgs.zenity}/bin/zenity --progress \
              --title="$_DISPLAY_NAME" \
              --text="Pulling image <b>$_IMAGE</b>…\n<small>This may take a few minutes.</small>" \
              --pulsate --auto-close --no-cancel --width=500 2>/dev/null || true

          if [ "$(cat "$_RC_FILE" 2>/dev/null)" != "0" ]; then
            rm -f "$_RC_FILE"
            zerror "Failed to pull image <b>$_IMAGE</b>.\nCheck your internet connection and that the image name is correct."
            exit 1
          fi

          # ── Step 2: create the container (image already cached, fast) ─────
          (
            ${pkgs.distrobox}/bin/distrobox create ${distroboxCreateFlags} 2>&1
            echo $? > "$_RC_FILE"
          ) | ${pkgs.zenity}/bin/zenity --progress \
              --title="$_DISPLAY_NAME" \
              --text="Initialising container <b>$CONTAINER</b>…" \
              --pulsate --auto-close --no-cancel --width=500 2>/dev/null || true

          if [ "$(cat "$_RC_FILE" 2>/dev/null)" != "0" ]; then
            rm -f "$_RC_FILE"
            zerror "Failed to create the Distrobox container.\nCheck the logs with: journalctl -xe"
            exit 1
          fi

          rm -f "$_RC_FILE"
        fi

                # Welcome popup + zip selection
        ${pkgs.zenity}/bin/zenity --info \
          --title="$_DISPLAY_NAME — Install" \
          --window-icon="$_ICON" \
          --text=${lib.escapeShellArg ui'.welcomeText} \
          --width=500 2>/dev/null || true

        ZIP_PATH=$(${pkgs.zenity}/bin/zenity --file-selection \
          --title=${lib.escapeShellArg ui'.selectZipTitle} \
          --file-filter="ZIP archives | *.zip" \
          --file-filter="All files | *" \
          2>/dev/null) || { zinfo "Installation cancelled."; exit 0; }

        [ -f "$ZIP_PATH" ] || { zerror "File not found:\n$ZIP_PATH"; exit 1; }

        ${zipValidationScript}

        # Run caller-defined install steps
        ${stepsScript}

        if [ ! -f "$BINARY" ]; then
          zerror ${lib.escapeShellArg ui'.errorBinaryNotFound}
          exit 1
        fi

        chmod +x "$BINARY" 2>/dev/null || true
        touch "$SENTINEL"

        # Swap to the post-install icon if available
        ${iconPostInstallScript}

        # Write the definitive .desktop (Exec points back to $0)
        mkdir -p "$(dirname "$_DESKTOP_FILE")"
        cat > "$_DESKTOP_FILE" << DESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=${displayName}
GenericName=${desktop'.genericName}
Comment=${desktop'.comment}
Exec=$0 %f
Icon=$_ICON
Terminal=false
StartupNotify=true
Categories=${desktop'.categories}
${desktopOptionalFields}
DESKTOP
        ${pkgs.desktop-file-utils}/bin/update-desktop-database \
          "$(dirname "$_DESKTOP_FILE")" 2>/dev/null || true

        ${pkgs.zenity}/bin/zenity --info \
          --title="$_DISPLAY_NAME" \
          --window-icon="$_ICON" \
          --text=${lib.escapeShellArg ui'.doneText} \
          --width=420 2>/dev/null || true
      '';

      # ── Uninstall procedure ────────────────────────────────────────────────
      # Restores the placeholder .desktop so the app can be reinstalled.
      placeholderDesktopContent = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${displayName}
        GenericName=${desktop'.genericName}
        Comment=${desktop'.comment} (click to install)
        Exec=EXEC_PLACEHOLDER %f
        Icon=${resolvedIcon}
        Terminal=false
        StartupNotify=true
        Categories=${desktop'.categories}
        ${desktopOptionalFields}
      '';

      placeholderDesktop = pkgs.writeText "${name}-placeholder.desktop"
        placeholderDesktopContent;

      uninstallProcedure = ''
        if ! zask ${lib.escapeShellArg ui'.uninstallConfirmText}; then
          exit 0
        fi

        zpulse "$_DISPLAY_NAME" "Removing container ${safeContainerName}…" \
          ${pkgs.distrobox}/bin/distrobox rm --force "$CONTAINER" 2>/dev/null || true

        zpulse "$_DISPLAY_NAME" "Removing files in ${installDir}…" \
          rm -rf "$INSTALL_DIR"

        rm -f "$SENTINEL"

        # Restore the placeholder .desktop with the correct Exec path ($0 is
        # still the launcher in the Nix store — it survives uninstall).
        sed "s|EXEC_PLACEHOLDER|$0|g" ${placeholderDesktop} > "$_DESKTOP_FILE"
        chmod 644 "$_DESKTOP_FILE"
        ${pkgs.desktop-file-utils}/bin/update-desktop-database \
          "$(dirname "$_DESKTOP_FILE")" 2>/dev/null || true

        zinfo ${lib.escapeShellArg ui'.uninstalledText}
      '';

      # ─────────────────────────────────────────────────────────────────────
      # Main launcher script
      # Behaviour:
      #   - Not installed        → run install wizard, then launch
      #   - Installed + args     → launch directly (e.g. open a project file)
      #   - Installed, no args   → management menu (Launch / Uninstall)
      # ─────────────────────────────────────────────────────────────────────
      launchScript = pkgs.writeShellScriptBin "${name}-launch" ''
        #!/usr/bin/env bash
        set -euo pipefail

        ${sharedEnv}
        ${sharedHelpers}

        if [ ! -f "$SENTINEL" ]; then
          ${installProcedure}
        fi

        if [ $# -gt 0 ]; then
          exec ${pkgs.distrobox}/bin/distrobox enter "$CONTAINER" -- ${environment} "$BINARY" "$@"
        fi

        CHOICE=$(${pkgs.zenity}/bin/zenity --list \
          --title="$_DISPLAY_NAME" \
          --window-icon="$_ICON" \
          --text="What would you like to do?" \
          --column="Action" \
          "Launch ${displayName}" \
          "Uninstall ${displayName}" \
          --width=360 --height=240 2>/dev/null) || exit 0

        case "$CHOICE" in
          "Launch ${displayName}")
            exec ${pkgs.distrobox}/bin/distrobox enter "$CONTAINER" -- "$BINARY"
            ;;
          "Uninstall ${displayName}")
            ${uninstallProcedure}
            ;;
        esac
      '';

      # ── Shell shortcut: drop into the container ────────────────────────────
      enterScript = pkgs.writeShellScriptBin "${name}" ''
        exec ${pkgs.distrobox}/bin/distrobox enter "${safeContainerName}" -- "''${@:-bash}"
      '';

      # ── Initial .desktop placed by the systemd user service ───────────────
      initialDesktop = pkgs.writeText "${name}.desktop" ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${displayName}
        GenericName=${desktop'.genericName}
        Comment=${desktop'.comment} (click to install)
        Exec=${launchScript}/bin/${name}-launch %f
        Icon=${resolvedIcon}
        Terminal=false
        StartupNotify=true
        Categories=${desktop'.categories}
        ${desktopOptionalFields}
      '';

    in {
      inherit launchScript enterScript initialDesktop;
      packages = [ launchScript enterScript ];
    };
}
