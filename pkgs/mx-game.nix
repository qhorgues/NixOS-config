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

  stopCmds = lib.concatMapStrings
    (svc: "  ${pkgs.systemd}/bin/systemctl --no-ask-password stop ${svc} 2>/dev/null || echo \"Warning: could not stop ${svc}\"\n")
    servicesToManage;

  startCmds = lib.concatMapStrings
    (svc: "  ${pkgs.systemd}/bin/systemctl --no-ask-password start ${svc} 2>/dev/null || echo \"Warning: failed to restart ${svc}\"\n")
    servicesToManage;

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

  cleanup() {
    echo "==> Restoring power profile to 'balanced'..."
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced

    ${fanAfterCmd}

    echo "==> Restarting services..."
    ${startCmds}
    echo "==> Done."
  }

  trap cleanup EXIT

  echo "==> Stopping services..."
  ${stopCmds}
  echo "==> Services stopped."

  echo "==> Setting power profile to 'performance'..."
  ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance

  ${fanBeforeCmd}

  echo "==> Running: $*"
  echo ""
  "$@" &
  child_pid=$!

  trap 'kill -TERM "$child_pid" 2>/dev/null' TERM INT

  wait "$child_pid"
  exit_code=$?

  exit $exit_code
''
