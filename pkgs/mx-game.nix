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

in
pkgs.writeShellScriptBin "mx-games" ''
    set -euo pipefail

    if [ $# -eq 0 ]; then
        echo "Usage: mx-games <command> [args...]"
        echo ""
        echo "Services managed (stopped before, restarted after):"
        echo "${lib.concatStringsSep "\n" (map (s: "  - ${s}") servicesToManage)}"
        exit 1
    fi

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

    echo "==> Running: $*"
    "$@" &
    child_pid=$!
    set +e
    wait "$child_pid"
    exit $?
''
