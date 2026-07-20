{ config, lib, pkgs, ... }:

let
  cfg = config.mx.services.remote-desktop;

  steamBigPicture = "sudo -u quentin ${pkgs.util-linux}/bin/setsid ${config.programs.steam.package}/bin/steam steam://open/bigpicture";

  sunshineAssets = "${config.services.sunshine.package}/assets";

  displaySwitch = pkgs.callPackage ../../../lib/display-switch.nix {
    displays = config.mx.virtual-display.displays;
  };
  activate = "${displaySwitch.activate}/bin/activate-virtual-display";
  restore = "${displaySwitch.restore}/bin/restore-display";

  mkPrepCmd = a: lib.optional (a.output != null) {
    do = "${activate} ${a.output}";
    undo = restore;
  };

  mkApp = a:
    let
      detached = lib.optional a.steam steamBigPicture ++ a.command;
      image =
        if a.image != null then a.image
        else if a.steam then "${sunshineAssets}/steam.png"
        else "${sunshineAssets}/desktop.png";
    in
    { inherit (a) name; image-path = image; }
    // lib.optionalAttrs (detached != [ ]) { inherit detached; }
    // lib.optionalAttrs (a.output != null) { prep-cmd = mkPrepCmd a; };

  switches = lib.any (a: a.output != null) cfg.app;
in
{
  options.mx.services.remote-desktop = {
    enable = lib.mkEnableOption "Enable remote desktop server";

    app = lib.mkOption {
      default = [ ];
      description = "Sunshine apps, each with its own name and resolution/output switch.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Application name shown in Moonlight.";
            example = "Steam Big Picture";
          };

          steam = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Auto-launch Steam Big Picture when this app starts.";
          };

          image = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Cover art shown in Moonlight (absolute path: sunshine runs PATH
              unset). null uses the default banner: Steam art when `steam = true`,
              else the desktop banner.
            '';
          };

          command = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Extra commands run detached when the app starts. Use absolute paths:
              the sunshine user service runs with PATH unset.
            '';
            example = [ "/run/current-system/sw/bin/mangohud" ];
          };

          output = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Output switched to while this app streams (e.g. "DP-2"): enabled alone
              with every other output off, then reset when the stream ends. The mode
              is driven by the Sunshine client request (SUNSHINE_CLIENT_WIDTH/HEIGHT/
              FPS), so the output — typically a mx.virtual-display output — must
              advertise that mode via its EDID; the display's configured mode is used
              as fallback. null keeps the current layout (no switch).
            '';
            example = "DP-2";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = true;
    };

    services.sunshine.applications.apps = map mkApp cfg.app;

    assertions = lib.optionals switches [
      {
        assertion = config.mx.virtual-display.enable;
        message = "mx.services.remote-desktop.app entries with an 'output' need mx.virtual-display.enable (it provides activate-virtual-display / restore-display).";
      }
    ];
  };
}
