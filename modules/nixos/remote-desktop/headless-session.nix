{ config, lib, pkgs, ... }:

let
  cfg = config.mx.services.remote-desktop;
  hcfg = cfg.headless;

  # Sunshine binary from the same package the service uses (so config/version match).
  sunshineBin = "${config.services.sunshine.package}/bin/sunshine";

  # What runs inside the streaming session. Defaults to Steam Big Picture; needs
  # programs.steam (mx.programs.games) enabled. Override for a different launcher.
  sessionCommand =
    if hcfg.sessionCommand != null then hcfg.sessionCommand
    else "${config.programs.steam.package}/bin/steam -gamepadui";

  # Minimal sway config: one fixed-mode headless output, launch Sunshine + the
  # game session. sway is a wlroots compositor, so Sunshine captures it natively
  # via wlr-screencopy/dmabuf (no KMS/DRM master, no VT-foreground dependency —
  # unlike GNOME/Mutter, which is why the quentin-session path uses display-switch).
  swayConfig = pkgs.writeText "mx-stream-sway.conf" ''
    output HEADLESS-1 mode ${toString hcfg.width}x${toString hcfg.height}@${toString hcfg.refreshRate}Hz
    output HEADLESS-1 pos 0 0

    # Unattended streaming box: never blank/idle the (virtual) output.
    exec ${sunshineBin}
    exec ${sessionCommand}
  '';

  # Launch sway headless. Run from the autologin *login shell* (below), not a bare
  # user service, so it inherits a real logind seat — wlroots needs one.
  sessionScript = pkgs.writeShellScript "mx-stream-session" ''
    export WLR_BACKENDS=headless
    export WLR_HEADLESS_OUTPUTS=1
    export WLR_LIBINPUT_NO_DEVICES=1
    export XDG_SESSION_TYPE=wayland
    exec ${pkgs.sway}/bin/sway --config ${swayConfig}
  '';

  # Login shell for the stream user: start the session only on its dedicated VT,
  # otherwise drop to an interactive shell (debugging). The user is autologin-only
  # (locked password), so in practice this always launches the session.
  # Tagged with shellPath so users.users.<n>.shell accepts it as a shell package.
  loginShell = (pkgs.writeShellScriptBin "mx-stream-login" ''
    if [ "$XDG_VTNR" = "${toString hcfg.vt}" ] && [ -z "$WAYLAND_DISPLAY" ]; then
      exec ${sessionScript}
    fi
    exec ${pkgs.bashInteractive}/bin/bash "$@"
  '') // { shellPath = "/bin/mx-stream-login"; };
in
{
  options.mx.services.remote-desktop.headless = {
    enable = lib.mkEnableOption ''
      a dedicated, unprivileged auto-login streaming session on its own VT.
      Sunshine and the game session run as an isolated `user`; your main account
      keeps its password-protected login on tty1. Intended for remote game
      streaming after a Wake-on-LAN boot, without exposing the privileged desktop
    '';

    user = lib.mkOption {
      type = lib.types.str;
      default = "stream";
      description = "Unprivileged user that owns the auto-login streaming session (never in wheel).";
    };

    vt = lib.mkOption {
      type = lib.types.ints.between 2 12;
      default = 7;
      description = ''
        Virtual terminal the streaming user auto-logs into. Kept clear of VT1
        (GDM greeter) and VT2 (first GDM session) so the main account's login
        stays reachable with Ctrl+Alt+F1.
      '';
    };

    width = lib.mkOption {
      type = lib.types.int;
      default = 1920;
      description = "Headless output width streamed to the client.";
    };

    height = lib.mkOption {
      type = lib.types.int;
      default = 1080;
      description = "Headless output height streamed to the client.";
    };

    refreshRate = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Headless output refresh rate (Hz).";
    };

    sessionCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/current-system/sw/bin/steam steam://open/bigpicture";
      description = ''
        Command launched inside the streaming session (absolute path). null uses
        Steam Big Picture, which requires mx.programs.games (programs.steam).
      '';
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra groups for the streaming user. wheel is never added.";
    };
  };

  config = lib.mkIf (cfg.enable && hcfg.enable) {
    # 1. Hardened, unprivileged streaming user. Locked password => autologin only,
    #    no console/SSH password login. GPU + input access for gaming and Sunshine's
    #    uinput injection; no wheel/sudo.
    users.users.${hcfg.user} = {
      isNormalUser = true;
      description = "Sunshine remote streaming session";
      hashedPassword = "!";
      createHome = true;
      home = "/home/${hcfg.user}";
      shell = loginShell;
      extraGroups = [ "video" "render" "input" "gamemode" ] ++ hcfg.extraGroups;
    };

    # 2. Auto-login on a dedicated VT via a getty drop-in. getty is not a display
    #    manager, so it coexists with GDM (which keeps tty1 for the main user).
    systemd.services."getty@tty${toString hcfg.vt}" = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "${pkgs.util-linux}/sbin/agetty --autologin ${hcfg.user} --noclear %I $TERM"
      ];
      # Force the VT up at boot so the session is ready without anyone switching to it.
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
    };

    # 3. Sunshine must run only in the stream session. The upstream user service
    #    would otherwise also start inside quentin's GNOME session and collide on
    #    ports, so disable autostart and let the sway session launch it (as its
    #    child it inherits WAYLAND_DISPLAY + the logind seat).
    services.sunshine.autoStart = lib.mkForce false;

    assertions = [
      {
        assertion = hcfg.sessionCommand != null || config.programs.steam.enable;
        message = "mx.services.remote-desktop.headless: the default sessionCommand is Steam Big Picture — enable mx.programs.games or set headless.sessionCommand.";
      }
      {
        assertion = hcfg.user != config.mx.main-user.userName;
        message = "mx.services.remote-desktop.headless.user must not be your main user — it is an isolated, unprivileged streaming account.";
      }
    ];
  };
}
