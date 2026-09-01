{ writeShellScriptBin }:

writeShellScriptBin "fw16-keyboard" ''
  set -eu

  usage() {
    echo "usage: fw16-keyboard on|off|status" >&2
    echo "  off     inhibit the internal keyboard and numpad modules" >&2
    echo "  on      re-enable them" >&2
    echo "  status  show the current state of each matched device" >&2
    exit 2
  }

  [ $# -eq 1 ] || usage

  case "$1" in
    on)     value=0 ;;
    off)    value=1 ;;
    status) value=  ;;
    *)      usage   ;;
  esac

  # Writing sysfs needs root; reading for `status` does not.
  if [ -n "$value" ] && [ "$EUID" -ne 0 ]; then
    exec /run/wrappers/bin/sudo -- "$0" "$@"
  fi

  found=0
  for dev in /sys/class/input/input*; do
    [ -r "$dev/name" ] || continue
    read -r name < "$dev/name"
    case "$name" in
      "Framework Laptop 16 Keyboard Module"*|"Framework Laptop 16 Numpad Module"*) ;;
      *) continue ;;
    esac
    [ -e "$dev/inhibited" ] || continue
    found=1

    if [ -z "$value" ]; then
      read -r cur < "$dev/inhibited"
      if [ "$cur" = 1 ]; then state=disabled; else state=enabled; fi
      printf '%-52s %s\n' "$name" "$state"
    else
      echo "$value" > "$dev/inhibited"
    fi
  done

  if [ "$found" -eq 0 ]; then
    echo "fw16-keyboard: no Framework Laptop 16 keyboard or numpad device found" >&2
    exit 1
  fi
''
