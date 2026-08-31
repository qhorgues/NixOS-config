{ config, lib, pkgs, ... }:

let
  cfg = config.mx.services.remote-login;

  user = "remote-login";

  runtimeDir = "/run/mx-remote-login";
  gdmConfLink = "${runtimeDir}/gdm-custom.conf";

  settingsFormat = pkgs.formats.ini { };
  gdmSettings = config.services.displayManager.gdm.settings;

  gdmPlainConf = settingsFormat.generate "gdm-custom.conf" gdmSettings;

  gdmAutoLoginConf = settingsFormat.generate "gdm-custom-autologin.conf" (
    gdmSettings // {
      daemon = (gdmSettings.daemon or { }) // {
        AutomaticLoginEnable = true;
        AutomaticLogin = user;
      };
    }
  );

  scriptPath = lib.makeBinPath [ pkgs.systemd pkgs.coreutils ];

  preamble = name: ''
    #!${pkgs.runtimeShell} -p
    set -euo pipefail
    export PATH=${scriptPath}

    if [ "$EUID" -ne 0 ]; then
      echo "${name}: must run through /run/wrappers/bin/${name}" >&2
      exit 1
    fi

    target_user=$(id -run)
    if [ "$target_user" != "${user}" ]; then
      echo "${name}: only ${user} may run this, not $target_user" >&2
      exit 1
    fi

    session_of_target() {
      local id name type
      while read -r id _; do
        [ -n "$id" ] || continue
        name=$(loginctl show-session "$id" --property=Name --value 2>/dev/null || true)
        [ "$name" = "$target_user" ] || continue
        type=$(loginctl show-session "$id" --property=Type --value 2>/dev/null || true)
        case "$type" in
          wayland|x11) printf '%s\n' "$id"; return 0 ;;
        esac
      done < <(loginctl list-sessions --no-legend)
      return 1
    }
  '';

  mkScript = name: body: pkgs.writeTextFile {
    inherit name;
    destination = "/bin/${name}";
    executable = true;
    text = preamble name + body;
    checkPhase = ''
      ${pkgs.stdenv.shellDryRun} "$target"
      ${pkgs.shellcheck-minimal}/bin/shellcheck --shell=bash "$target"
    '';
  };

  loginScript = mkScript "mx-remote-login" ''
    other_graphical_session() {
      local id name class type
      while read -r id _; do
        [ -n "$id" ] || continue
        name=$(loginctl show-session "$id" --property=Name --value 2>/dev/null || true)
        class=$(loginctl show-session "$id" --property=Class --value 2>/dev/null || true)
        type=$(loginctl show-session "$id" --property=Type --value 2>/dev/null || true)
        if [ "$name" != "$target_user" ] && [ "$class" = "user" ] &&
           { [ "$type" = "wayland" ] || [ "$type" = "x11" ]; }; then
          printf '%s\n' "$name"
          return 0
        fi
      done < <(loginctl list-sessions --no-legend)
      return 1
    }

    force=0
    case "''${1-}" in
      --force) force=1 ;;
      "") ;;
      *) echo "usage: mx-remote-login [--force]" >&2; exit 2 ;;
    esac

    if sid=$(session_of_target); then
      if [ "$(loginctl show-session "$sid" --property=LockedHint --value)" = "yes" ]; then
        loginctl unlock-session "$sid"
      fi
      loginctl activate "$sid"
      echo "mx-remote-login: session $sid of $target_user unlocked and activated"
      exit 0
    fi

    if other=$(other_graphical_session); then
      if [ "$force" -eq 0 ]; then
        echo "mx-remote-login: $other has an active graphical session;" \
             "restarting the display manager would kill it. Re-run with --force." >&2
        exit 3
      fi
      echo "mx-remote-login: --force given, destroying the graphical session of $other" >&2
    fi

    mkdir -p ${runtimeDir}
    trap 'ln -sfn ${gdmPlainConf} ${gdmConfLink}' EXIT

    ln -sfn ${gdmAutoLoginConf} ${gdmConfLink}
    systemctl restart display-manager.service

    for _ in $(seq 60); do
      if sid=$(session_of_target); then
        loginctl activate "$sid"
        echo "mx-remote-login: session $sid opened for $target_user"
        exit 0
      fi
      sleep 1
    done

    echo "mx-remote-login: no session for $target_user after 60s" >&2
    exit 4
  '';

  logoutScript = mkScript "mx-remote-logout" ''
    if ! sid=$(session_of_target); then
      echo "mx-remote-logout: no graphical session for $target_user"
      exit 0
    fi

    loginctl terminate-session "$sid"
    echo "mx-remote-logout: session $sid of $target_user terminated"
  '';
in
{
  imports = [ ../core/options/desktop.nix ];

  options.mx.services.remote-login = {
    enable = lib.mkEnableOption "SSH driven login/unlock of the ${user} streaming session";

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Public keys allowed to log in as ${user} over SSH, i.e. the keys of the
        streaming clients that send the Wake-on-LAN magic packet.
      '';
      example = [ "ssh-ed25519 AAAAC3Nz... moonlight-client" ];
    };

    wakeOnLan.interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Interfaces to enable Wake-on-LAN on. Wake from a full power off also
        needs to be enabled in the motherboard firmware.
      '';
      example = [ "enp4s0" ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.mx.desktop.environment == "gnome";
        message = "mx.services.remote-login drives GDM: it needs mx.desktop.environment = \"gnome\".";
      }
      {
        assertion = config.services.openssh.enable;
        message = "mx.services.remote-login is triggered over SSH: it needs services.openssh.enable.";
      }
      {
        assertion = config.mx.services.remote-desktop.enable;
        message = "mx.services.remote-login opens the session of ${user}, which is created by mx.services.remote-desktop.";
      }
      {
        assertion = cfg.authorizedKeys != [ ];
        message = "mx.services.remote-login.authorizedKeys is empty: no client could log in as ${user} to trigger the session.";
      }
    ];

    environment.etc."gdm/custom.conf".source = lib.mkForce gdmConfLink;

    systemd.tmpfiles.rules = [
      "d ${runtimeDir} 0755 root root -"
      "L+ ${gdmConfLink} - - - - ${gdmPlainConf}"
    ];

    services.openssh = {
      openFirewall = true;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        KbdInteractiveAuthentication = lib.mkDefault false;
      };
    };

    users.groups.${user} = { };
    users.users.${user} = {
      extraGroups = [ user ];
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
      packages = [ pkgs.firefox-bin pkgs.gnome-console ];
    };

    security.wrappers = {
      mx-remote-login = {
        setuid = true;
        owner = "root";
        group = user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${loginScript}/bin/mx-remote-login";
      };
      mx-remote-logout = {
        setuid = true;
        owner = "root";
        group = user;
        permissions = "u+rx,g+x,o-rwx";
        source = "${logoutScript}/bin/mx-remote-logout";
      };
    };

    networking.interfaces = lib.genAttrs cfg.wakeOnLan.interfaces (_: {
      wakeOnLan.enable = true;
    });

    networking.firewall.allowedUDPPorts = [ 9 ];
  };
}
