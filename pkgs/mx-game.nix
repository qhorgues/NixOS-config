{
  lib,
  pkgs,
  dockerEnable ? false,
  ollamaEnable ? false,
  open-webuiEnable ? false,
  lampEnable ? false,
  postgresEnable ? false,
  printingEnable ? false,
  teamviewerEnable ? false,
  vmEnable ? false,
  fwFanCtrl ? false,
  desktop ? "none",
  enableHDR ? false,
}:
let
  serviceMap = {
    docker     = lib.optionals dockerEnable     [ "docker.service" "docker.socket" ];
    ollama     = lib.optionals ollamaEnable     [ "ollama.service" ];
    open-webui = lib.optionals open-webuiEnable [ "open-webui.service" ];
    lamp       = lib.optionals lampEnable       [ "httpd.service" "mysql.service" ];
    postgres   = lib.optionals postgresEnable   [ "postgresql.service" ];
    printing   = lib.optionals printingEnable   [ "cups.service" "cups.socket" ];
    teamviewer = lib.optionals teamviewerEnable [ "teamviewerd.service" ];
    vm         = lib.optionals vmEnable         [ "libvirtd.service" "libvirtd.socket" "virtlogd.service" "virtlogd.socket" ];
  };

  servicesToManage = lib.flatten (lib.attrValues serviceMap);

  servicesStr = lib.concatStringsSep " " servicesToManage;

  stopCmds = lib.optionalString (servicesToManage != []) ''
    ${pkgs.systemd}/bin/systemctl --no-ask-password --no-block stop ${servicesStr} 2>/dev/null \
      || echo "Warning: could not stop some services"
  '';
  startCmds = lib.optionalString (servicesToManage != []) ''
    ${pkgs.systemd}/bin/systemctl --no-ask-password start ${servicesStr} 2>/dev/null \
      || echo "Warning: could not restart some services"
  '';


  fanBeforeCmd  = lib.optionalString fwFanCtrl ''
    echo "==> Setting fan profile to 'medium'..."
    ${pkgs.fw-fanctrl}/bin/fw-fanctrl use medium
  '';
  fanAfterCmd   = lib.optionalString fwFanCtrl ''
    echo "==> Restoring fan profile to 'lazy'..."
    ${pkgs.fw-fanctrl}/bin/fw-fanctrl use lazy
  '';

  primaryMode = pkgs.callPackage ./mx-primary-mode.nix { };

  detectCmds = {
    gnome = "${primaryMode}/bin/mx-primary-mode";

    plasma = ''
      ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor -j \
        | ${pkgs.jq}/bin/jq -r '[.outputs[] | select(.enabled)] as $o
            | (([$o[] | select(.primary)] + $o)[0]) as $m
            | ($m.currentModeId // "") as $id
            | (([$m.modes[] | select(.id == $id)] + [$m.modes[] | select(.current)])[0])
            | "\(.size.width)x\(.size.height)@\(.refreshRate)"'
    '';

    lxqt = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --current | ${pkgs.gawk}/bin/awk '
        /^[^[:space:]]+ connected/ { prim = ($3 == "primary"); next }
        /^[[:space:]]+[0-9]+x[0-9]+[[:space:]]/ {
          for (i = 2; i <= NF; i++) if ($i ~ /\*/) {
            r = $i; gsub(/[^0-9.]/, "", r); m = $1 "@" r
            if (prim) { if (!p) p = m } else if (!f) f = m
            break
          }
        }
        END { if (p) print p; else if (f) print f }
      '
    '';
  };

  detectCmd = detectCmds.${desktop} or "false";

  gamescopeArgs = [ "-f" "--adaptive-sync" "--mangoapp" "--rt" "--force-grab-cursor" "--immediate-flips" ]
    ++ lib.optional enableHDR "--hdr-enabled";

  gamescopeEnv = ''
    export ENABLE_GAMESCOPE_WSI=1
    export LD_PRELOAD=""
    ${lib.optionalString enableHDR "export DXVK_HDR=1"}
  '';

in
pkgs.writeShellScriptBin "mx-games" ''
    set -euo pipefail

    if [ $# -eq 0 ]; then
        echo "Usage: mx-games [--no-gamescope] <command> [args...]"
        echo ""
        echo "The command is wrapped in gamescope (${lib.concatStringsSep " " gamescopeArgs})"
        echo "at the resolution and refresh rate of the main screen, detected for"
        echo "desktop '${desktop}'."
        echo ""
        echo "Options:"
        echo "  --no-gamescope            run the command directly (also: MX_GAMES_NO_GAMESCOPE=1)"
        echo ""
        echo "Environment:"
        echo "  MX_GAMES_RESOLUTION=WxH   override the detected resolution"
        echo "  MX_GAMES_REFRESH=HZ       override the detected refresh rate (0 disables -r)"
        echo ""
        echo "Setting MX_GAMES_RESOLUTION alone still uses the detected refresh rate;"
        echo "set both to force a full mode."
        echo ""
        echo "Services managed (stopped before, restarted after):"
        echo "${lib.concatStringsSep "\n" (map (s: "  - ${s}") servicesToManage)}"
        exit 1
    fi

    use_gamescope=1
    if [ "''${MX_GAMES_NO_GAMESCOPE:-0}" = "1" ]; then
        use_gamescope=0
    fi
    if [ "$1" = "--no-gamescope" ]; then
        use_gamescope=0
        shift
        if [ $# -eq 0 ]; then
            echo "Usage: mx-games [--no-gamescope] <command> [args...]" >&2
            exit 1
        fi
    fi

    detect_mode() {
        local mode=""
        mode="$(${detectCmd} 2>/dev/null | head -n1 || true)"
        if ! [[ "$mode" =~ ^[0-9]+x[0-9]+(@[0-9.]+)?$ ]]; then
            for modes in /sys/class/drm/card*-eDP*/modes /sys/class/drm/card*-*/modes; do
                [ -r "$modes" ] || continue
                mode="$(head -n1 "$modes" || true)"
                [[ "$mode" =~ ^[0-9]+x[0-9]+$ ]] && break
            done
        fi
        [[ "$mode" =~ ^[0-9]+x[0-9]+(@[0-9.]+)?$ ]] || mode="1920x1080"
        printf '%s' "$mode"
    }

    child_pid=""

    cleanup() {
        set +e
        echo "==> Restoring power profile to 'balanced'..."
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
        ${fanAfterCmd}
        echo "==> Restarting services..."
        ${startCmds}
        echo "==> Done."
    }
    trap cleanup EXIT

    forward_signal() {
      [ -n "$child_pid" ] && kill -"$1" "$child_pid" 2>/dev/null || true
    }
    trap 'forward_signal TERM' TERM
    trap 'forward_signal INT'  INT

    echo "==> Stopping services..."
    ${stopCmds}
    echo "==> Setting power profile to 'performance'..."
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
    ${fanBeforeCmd}

    if [ "$use_gamescope" = "1" ]; then
        mode="$(detect_mode)"

        resolution="''${MX_GAMES_RESOLUTION:-''${mode%@*}}"
        if ! [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
            echo "Error: invalid resolution '$resolution' (expected WxH)" >&2
            exit 1
        fi
        width="''${resolution%x*}"
        height="''${resolution#*x}"

        detected_refresh=""
        case "$mode" in *@*) detected_refresh="''${mode#*@}" ;; esac
        refresh="''${MX_GAMES_REFRESH:-$detected_refresh}"

        refresh_args=()
        mode_desc="$resolution"
        if [[ "$refresh" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            refresh="$(LC_ALL=C printf '%.0f' "$refresh")"
            if [ "$refresh" -gt 0 ]; then
                refresh_args=(-r "$refresh")
                mode_desc="$resolution@''${refresh}Hz"
            fi
        elif [ -n "$refresh" ]; then
            echo "Error: invalid refresh rate '$refresh' (expected Hz)" >&2
            exit 1
        fi

        ${gamescopeEnv}
        echo "==> Running under gamescope ($mode_desc): $*"
        ${pkgs.gamescope}/bin/gamescope ${lib.concatStringsSep " " gamescopeArgs} \
            -W "$width" -H "$height" "''${refresh_args[@]}" -- "$@" &
    else
        echo "==> Running: $*"
        "$@" &
    fi
    child_pid=$!
    set +e
    wait "$child_pid"
    exit $?
''
