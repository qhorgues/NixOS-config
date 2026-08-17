{
  lib,
  pkgs,
  services ? [ ],
  fwFanCtrl ? false,
  desktop ? "none",
  enableHDR ? false,
  obsCapture ? false,
}:
let
  servicesToManage = services;

  obsGameCapture = lib.optionalString obsCapture
    "${pkgs.obs-studio-plugins.obs-vkcapture}/bin/obs-gamecapture";

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

  defaultFlags = [ "-f" "--adaptive-sync" "--mangoapp" "--rt" "--force-grab-cursor" "--immediate-flips" ]
    ++ lib.optional enableHDR "--hdr-enabled";

  defaultFlagsStr = lib.concatStringsSep " " defaultFlags;

in
pkgs.writeShellScriptBin "mx-games" ''
    set -euo pipefail

    usage() {
        echo "Usage: mx-games [options] <command> [args...]"
        echo ""
        echo "The command is wrapped in gamescope (${defaultFlagsStr})"
        echo "at the resolution and refresh rate of the main screen, detected for"
        echo "desktop '${desktop}'."
        echo ""
        echo "Options:"
        echo "  --no-gamescope            run the command directly (also: MX_GAMES_NO_GAMESCOPE=1)"
        echo "  --no-fullscreen           drop -f"
        echo "  --no-adaptive-sync        drop --adaptive-sync"
        echo "  --no-mangoapp             drop --mangoapp"
        echo "  --no-rt                   drop --rt"
        echo "  --no-force-grab-cursor    drop --force-grab-cursor"
        echo "  --no-immediate-flips      drop --immediate-flips"
        echo "  --no-hdr                  drop --hdr-enabled (and DXVK_HDR)"
        echo "  --no-obs-capture          drop obs-vkcapture (also: MX_GAMES_OBS_CAPTURE=0)"
        echo "  --obs-capture             re-add it. On by default when OBS Studio is"
        echo "                            installed; covers Vulkan and OpenGL games."
        echo "                            gamescope and mangoapp never capture, so only"
        echo "                            the game claims the OBS socket."
        echo ""
        echo "Environment:"
        echo "  MX_GAMES_GAMESCOPE_ARGS   extra gamescope args, split on whitespace (no quote"
        echo "                            handling: a value must not contain a space). An arg"
        echo "                            setting an option the script also sets (-W/-H/-r, or"
        echo "                            -b/--borderless against -f) replaces it instead of"
        echo "                            being added twice, and wins over MX_GAMES_RESOLUTION"
        echo "                            and MX_GAMES_REFRESH."
        echo "  MX_GAMES_RESOLUTION=WxH   override the detected resolution"
        echo "  MX_GAMES_REFRESH=HZ       override the detected refresh rate (0 disables -r)"
        echo ""
        echo "Setting MX_GAMES_RESOLUTION alone still uses the detected refresh rate;"
        echo "set both to force a full mode."
        echo ""
        echo "Examples:"
        echo "  MX_GAMES_GAMESCOPE_ARGS=\"--framerate-limit 2 -F fsr\" mx-games steam"
        echo "  MX_GAMES_GAMESCOPE_ARGS=\"-W 2560 -H 1440 -r 60\" mx-games ./game"
        echo "  mx-games --no-mangoapp -- ./game"
        echo ""
        echo "Services managed (stopped before, restarted after):"
        echo "${lib.concatStringsSep "\n" (map (s: "  - ${s}") servicesToManage)}"
    }

    use_gamescope=1
    if [ "''${MX_GAMES_NO_GAMESCOPE:-0}" = "1" ]; then
        use_gamescope=0
    fi

    want_fullscreen=1
    want_adaptive_sync=1
    want_mangoapp=1
    want_rt=1
    want_force_grab_cursor=1
    want_immediate_flips=1
    want_hdr=${if enableHDR then "1" else "0"}

    obs_capture_bin="${obsGameCapture}"
    obs_capture=0
    if [ -n "$obs_capture_bin" ]; then
        obs_capture=1
    fi
    case "''${MX_GAMES_OBS_CAPTURE:-}" in
        1) obs_capture=1 ;;
        0) obs_capture=0 ;;
    esac

    while [ $# -gt 0 ]; do
        case "$1" in
            --no-gamescope)         use_gamescope=0 ;;
            --no-fullscreen)        want_fullscreen=0 ;;
            --no-adaptive-sync)     want_adaptive_sync=0 ;;
            --no-mangoapp)          want_mangoapp=0 ;;
            --no-rt)                want_rt=0 ;;
            --no-force-grab-cursor) want_force_grab_cursor=0 ;;
            --no-immediate-flips)   want_immediate_flips=0 ;;
            --no-hdr)               want_hdr=0 ;;
            --obs-capture)          obs_capture=1 ;;
            --no-obs-capture)       obs_capture=0 ;;
            -h|--help)              usage; exit 0 ;;
            --)                     shift; break ;;
            --*)                    echo "Error: unknown option '$1'" >&2; usage >&2; exit 1 ;;
            *)                      break ;;
        esac
        shift
    done

    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    if [ "$obs_capture" = "1" ] && [ -z "$obs_capture_bin" ]; then
        echo "Error: obs capture requires OBS Studio (mx.programs.obs-studio.enable)" >&2
        exit 1
    fi

    capture_cmd=()
    if [ "$obs_capture" = "1" ]; then
        capture_cmd=("$obs_capture_bin")
    fi

    user_gs_args=()
    if [ -n "''${MX_GAMES_GAMESCOPE_ARGS:-}" ]; then
        read -r -a user_gs_args <<< "$MX_GAMES_GAMESCOPE_ARGS" || true
    fi

    declare -A user_keys=()
    for arg in ''${user_gs_args[@]+"''${user_gs_args[@]}"}; do
        case "$arg" in
            --*=*)               user_keys["''${arg%%=*}"]=1 ;;
            -[WHwhrmSFsRTCoO]?*) user_keys["''${arg:0:2}"]=1 ;;
            -*)                  user_keys["$arg"]=1 ;;
        esac
    done

    # gs_has <opt>... : true if the user passed any of these spellings.
    gs_has() {
        local o
        for o in "$@"; do
            [ -n "''${user_keys[$o]:-}" ] && return 0
        done
        return 1
    }

    if [ "$use_gamescope" = "0" ] && [ ''${#user_gs_args[@]} -gt 0 ]; then
        echo "Warning: MX_GAMES_GAMESCOPE_ARGS ignored (gamescope disabled)" >&2
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
        gs_args=()

        # -b/--borderless from the user replaces -f (gamescope would set both).
        if ! gs_has -f --fullscreen -b --borderless && [ "$want_fullscreen" = "1" ]; then
            gs_args+=(-f)
        fi
        if ! gs_has --adaptive-sync && [ "$want_adaptive_sync" = "1" ]; then
            gs_args+=(--adaptive-sync)
        fi
        if ! gs_has --mangoapp && [ "$want_mangoapp" = "1" ]; then
            gs_args+=(--mangoapp)
        fi
        if ! gs_has --rt && [ "$want_rt" = "1" ]; then
            gs_args+=(--rt)
        fi
        if ! gs_has --force-grab-cursor && [ "$want_force_grab_cursor" = "1" ]; then
            gs_args+=(--force-grab-cursor)
        fi
        if ! gs_has --immediate-flips && [ "$want_immediate_flips" = "1" ]; then
            gs_args+=(--immediate-flips)
        fi
        if ! gs_has --hdr-enabled && [ "$want_hdr" = "1" ]; then
            gs_args+=(--hdr-enabled)
        fi

        if gs_has -W --output-width;   then user_w=1; else user_w=0; fi
        if gs_has -H --output-height;  then user_h=1; else user_h=0; fi
        if gs_has -r --nested-refresh; then user_r=1; else user_r=0; fi

        if [ "$user_w" = "1" ] && [ "$user_h" = "1" ] && [ "$user_r" = "1" ]; then
            mode_desc="mode from MX_GAMES_GAMESCOPE_ARGS"
        else
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

            if [ "$user_w" = "0" ]; then gs_args+=(-W "$width"); fi
            if [ "$user_h" = "0" ]; then gs_args+=(-H "$height"); fi
            if [ "$user_r" = "0" ] && [ ''${#refresh_args[@]} -gt 0 ]; then
                gs_args+=("''${refresh_args[@]}")
            fi

            if [ "$user_w" = "1" ] || [ "$user_h" = "1" ] || [ "$user_r" = "1" ]; then
                mode_desc="$mode_desc, partly overridden by MX_GAMES_GAMESCOPE_ARGS"
            fi
        fi

        export ENABLE_GAMESCOPE_WSI=1
        export LD_PRELOAD=""
        if [ "$want_mangoapp" = "1" ] || gs_has --mangoapp; then
            export MANGOHUD=0
        fi
        if [ "$want_hdr" = "1" ] || gs_has --hdr-enabled; then
            export DXVK_HDR=1
        fi

        gs_prefix=(${pkgs.coreutils}/bin/env DISABLE_OBS_VKCAPTURE=1)
        child_prefix=(${pkgs.coreutils}/bin/env -u DISABLE_OBS_VKCAPTURE)

        echo "==> Running under gamescope ($mode_desc): $*"
        ''${gs_prefix[@]+"''${gs_prefix[@]}"} ${pkgs.gamescope}/bin/gamescope "''${gs_args[@]}" \
            ''${user_gs_args[@]+"''${user_gs_args[@]}"} \
            -- ''${child_prefix[@]+"''${child_prefix[@]}"} \
               ''${capture_cmd[@]+"''${capture_cmd[@]}"} "$@" &
    else
        echo "==> Running: $*"
        ''${capture_cmd[@]+"''${capture_cmd[@]}"} "$@" &
    fi
    child_pid=$!
    set +e
    wait "$child_pid"
    exit $?
''
