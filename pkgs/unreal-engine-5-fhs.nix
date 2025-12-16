{ pkgs ? import <nixpkgs> {} }:

let
  unrealEngine = (pkgs.buildFHSEnv or pkgs.buildFHSUserEnv) {
    name = "unreal-engine";

    targetPkgs = pkgs: with pkgs; [
      gcc clang cmake gnumake git
      glibc stdenv.cc.cc.lib zlib
      xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXi
      xorg.libXxf86vm xorg.libXinerama xorg.libXScrnSaver
      xorg.libXext xorg.libSM xorg.libICE xorg.libXcomposite
      xorg.libXdamage xorg.libXfixes xorg.libXrender xorg.libXtst
      libxkbcommon
      libxcb
      libGL libGLU mesa vulkan-loader vulkan-tools libgbm
      SDL2 SDL2_image SDL2_ttf SDL2_mixer
      alsa-lib pulseaudio libpulseaudio
      fontconfig freetype
      gtk3 glib cairo pango gdk-pixbuf atk
      openssl curl dbus nspr nss cups expat libdrm wayland
      systemd udev
      python3 mono dotnet-sdk file which unzip
    ];

    profile = ''
      export SHELL=${pkgs.bash}/bin/bash

      # Force use of system memory allocator instead of mimalloc
      export UE_USE_MALLOC_REPLAY_PROXY=0
      export UE_USE_MALLOC_PROFILER=0

      # Disable some problematic features
      export MALLOC_CHECK_=0

      # Set thread stack size
      ulimit -s unlimited 2>/dev/null || true
    '';

    runScript = pkgs.writeShellScript "unreal-launcher" ''
      # Configuration file for installation path
      CONFIG_FILE="$HOME/.config/unreal-engine/install-path"
      DEFAULT_PATH="$HOME/.local/share/UnrealEngine"

      # Read installation path
      get_install_path() {
        if [ -f "$CONFIG_FILE" ]; then
          cat "$CONFIG_FILE"
        else
          echo "$DEFAULT_PATH"
        fi
      }

      # Save installation path
      set_install_path() {
        local path="$1"
        mkdir -p "$(dirname "$CONFIG_FILE")"
        echo "$path" > "$CONFIG_FILE"
        echo "Installation path configured: $path"
      }

      UE_DIR="$(get_install_path)"
      UE_EDITOR="$UE_DIR/Engine/Binaries/Linux/UnrealEditor"

      # Help function
      show_help() {
        cat << EOF
Usage: unreal-engine [COMMAND] [OPTIONS]

Commands:
  install <file.zip> [path]  Install Unreal Engine from ZIP archive
                              (optional path, default: $DEFAULT_PATH)
  run [args...]               Launch Unreal Engine Editor
  set-path <path>             Change installation path
  get-path                    Display current installation path
  help                        Display this help

Examples:
  # Install to default path
  unreal-engine install ~/Downloads/Linux_Unreal_Engine_5.7.1.zip

  # Install to custom location
  unreal-engine install ~/Downloads/UE.zip /opt/UnrealEngine

  # Change installation path
  unreal-engine set-path /mnt/games/UnrealEngine

  # Launch editor
  unreal-engine run

  # Launch with specific project
  unreal-engine run /path/to/project.uproject

Current installation path: $UE_DIR
EOF
      }

      # Installation function
      install_unreal() {
        local zip_file="$1"
        local install_path="''${2:-$UE_DIR}"

        if [ -z "$zip_file" ]; then
          echo "Error: Please specify ZIP file"
          echo "Usage: unreal-engine install <file.zip> [path]"
          exit 1
        fi

        # Expand ~ if present
        zip_file="''${zip_file/#\~/$HOME}"
        install_path="''${install_path/#\~/$HOME}"

        if [ ! -f "$zip_file" ]; then
          echo "Error: File '$zip_file' does not exist"
          exit 1
        fi

        echo "Installing Unreal Engine"
        echo "Installation path: $install_path"
        echo ""

        # Ask for confirmation if directory already exists
        if [ -d "$install_path" ] && [ "$(ls -A "$install_path" 2>/dev/null)" ]; then
          echo "Warning: Directory already exists and is not empty"
          read -p "Do you want to continue and overwrite contents? (y/N) " -n 1 -r
          echo ""
          if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled"
            exit 1
          fi
          echo "Removing old content..."
          rm -rf "$install_path"/*
        fi

        # Create directory
        mkdir -p "$install_path"

        # Save path if different from default
        if [ "$install_path" != "$DEFAULT_PATH" ]; then
          set_install_path "$install_path"
          UE_DIR="$install_path"
          UE_EDITOR="$UE_DIR/Engine/Binaries/Linux/UnrealEditor"
        fi

        # Extract archive
        echo "Extracting archive (this may take several minutes)..."
        echo "Please be patient..."

        if ! unzip -q "$zip_file" -d "$install_path"; then
          echo "Error during extraction"
          exit 1
        fi

        # Make files executable
        echo "Setting permissions..."
        find "$install_path" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        chmod +x "$install_path"/Engine/Binaries/Linux/* 2>/dev/null || true

        # Check if Setup.sh exists and run it
        if [ -f "$install_path/Setup.sh" ]; then
          echo "Running Setup.sh configuration script..."
          cd "$install_path"
          ./Setup.sh
        fi

        echo ""
        echo "Installation completed successfully!"
        echo ""
        echo "To launch Unreal Engine:"
        echo "  unreal-engine run"
        echo ""
        echo "Installation path: $install_path"
      }

      # Function to launch editor
      run_unreal() {
        if [ ! -f "$UE_EDITOR" ]; then
          echo "Error: Unreal Engine is not installed at: $UE_DIR"
          echo ""
          echo "Checked paths:"
          echo "  - Directory: $UE_DIR"
          echo "  - Editor: $UE_EDITOR"
          echo ""
          echo "To install, use:"
          echo "  unreal-engine install <file.zip> [path]"
          echo ""
          echo "To change installation path:"
          echo "  unreal-engine set-path <new-path>"
          exit 1
        fi

        echo "Launching Unreal Engine..."
        echo "From: $UE_DIR"
        cd "$UE_DIR"

        # Set additional runtime options to avoid crashes
        export LD_PRELOAD=""
        export MALLOC_CHECK_=0

        # Use system allocator instead of mimalloc (helps with segfaults)
        exec "$UE_EDITOR" -stdmalloc "$@"
      }

      # Parse arguments
      case "''${1:-help}" in
        install)
          shift
          install_unreal "$@"
          ;;
        run)
          shift
          run_unreal "$@"
          ;;
        set-path)
          if [ -z "$2" ]; then
            echo "Error: Please specify a path"
            echo "Usage: unreal-engine set-path <path>"
            exit 1
          fi
          set_install_path "''${2/#\~/$HOME}"
          ;;
        get-path)
          echo "$UE_DIR"
          ;;
        help|--help|-h)
          show_help
          ;;
        *)
          echo "Error: Unknown command: $1"
          echo ""
          show_help
          exit 1
          ;;
      esac
    '';
  };

in pkgs.symlinkJoin {
  name = "unreal-engine-with-desktop";
  paths = [ unrealEngine ];
  buildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    mkdir -p $out/share/applications
    cat > $out/share/applications/unreal-engine.desktop <<'EOF'
[Desktop Entry]
Name=Unreal Engine
Comment=Unreal Engine 5 Editor
Exec=unreal-engine run
Icon=unreal-engine
Terminal=false
Type=Application
Categories=Development;IDE;Graphics;
StartupNotify=true
EOF
  '';
}
