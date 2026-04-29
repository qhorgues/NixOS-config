{ config, pkgs, pkgs-unstable, lib, ... }:

let
  cfg = config.mx.programs.games;
  cgpu = config.mx.hardware.gpu;
  lsfg-vk = pkgs.callPackage ../../../pkgs/lsfg-vk.nix { };
  lsfg-vk-ui = pkgs.callPackage ../../../pkgs/lsfg-vk-ui.nix { };
  conf_service = config.mx.services;

  mx-game = import ../../../pkgs/mx-game.nix {
    lib = lib;
    pkgs = pkgs;
    dockerEnable = conf_service.docker.enable;
    ollamaEnable = conf_service.llm.enable;
    open-webuiEnable = conf_service.llm.open-webui.enable;
    lampEnable = conf_service.lamp.enable;
    postgresEnable = conf_service.postgresql.enable;
    printingEnable = conf_service.printing.enable;
    teamviewerEnable = config.mx.programs.team-viewer.enable;
    vmEnable = conf_service.vm.enable;
    fwFanCtrl = config.mx.hardware.framework-fan-ctrl.enable;
  };

  mkFhsDesktop = pkg: desktopFile: bin:
    pkg.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        sed -i 's|Exec=${bin}|Exec=${pkgs.steam}/bin/steam-run ${pkg}/bin/${bin}|g' \
          $out/share/applications/${desktopFile}
      '';
    });

  lsfg-vk-ui-fhs = mkFhsDesktop lsfg-vk-ui "gay.pancake.lsfg-vk-ui.desktop" "lsfg-vk-ui";

in
{

  options.mx.programs.games = {
    enable = lib.mkEnableOption "Enable Game config";

    force-fsr4-for-rdna3 = lib.mkEnableOption "Force FSR4 on AMD 7000 series";

    lsfg = {
      enable = lib.mkEnableOption "Install Losseless Scaling (required Lossless scaling app on Steam) but not enable by default";
      activate_on_all_games = lib.mkEnableOption "Activate Lossless Scaling on all games by default";

      steam_library_for_lossless_scaling = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to lossless scaling DLL";
      };
    };

    gamemode.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users for gamemode permissions should be enabled.";
    };

    heroic.enable = lib.mkEnableOption "Install heroic";
    lutris.enable = lib.mkEnableOption "Install lutris";
    umu.enable = lib.mkEnableOption "Install UMU";

    latest-unstable-mesa-driver.enable = lib.mkEnableOption "Enable latest unstable Mesa driver";

    cachyos-kernel.enable = lib.mkEnableOption "Enable optimized gaming CachyOS kernel";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--rt"
          "--expose-wayland"
        ];
        env = {
          TZ = ":/etc/localtime";
          XKB_DEFAULT_LAYOUT="fr";
          XKB_DEFAULT_VARIANT="latin9";
          XKB_DEFAULT_OPTIONS="grp:alt_shift_toggle";
        };
      };
      gamemode.enable = true;
      steam = {
        enable = true;
        gamescopeSession = {
            enable = true;
        };
        remotePlay.openFirewall = false;
        dedicatedServer.openFirewall = false;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = [ ]
        ++ lib.optionals cfg.lsfg.enable [
          lsfg-vk
          lsfg-vk-ui-fhs
        ];
        extraCompatPackages = [
          pkgs-unstable.proton-ge-bin
        ];
        package = pkgs.steam.override {
          extraEnv = {
            TZ = ":/etc/localtime";
            MANGOHUD = true;
            PROTON_ENABLE_WAYLAND=true;
            OBS_VKCAPTURE = config.mx.programs.obs-studio.enable;
            # PROTON_NO_D3D12=true;

            PROTON_FSR4_UPGRADE = cgpu.vendor == "amd"
                                  && cgpu.generation == "rdna4";
            PROTON_FSR4_RDNA3_UPGRADE = cgpu.vendor == "amd"
                                        && cgpu.generation == "rdna3"
                                        && cfg.force-fsr4-for-rdna3;
            PROTON_FSR3_UPGRADE = cgpu.generation == "rdna3"
                                  && (!cfg.force-fsr4-for-rdna3);
            PROTON_DLSS_UPGRADE = cgpu.vendor == "nvidia";
            PROTON_XESS_UPGRADE = cgpu.vendor == "intel"
                                  || (cgpu.vendor == "amd"
                                      && cgpu.generation != "rdna4");
          } //
          (if config.mx.programs.games.lsfg.enable == true then {
            VK_LAYER_PATH= "${lsfg-vk}/share/vulkan/explicit_layer.d";
            LSFG_LEGACY=1;
          } else {})
          //
          (if config.mx.programs.games.lsfg.enable == true && config.mx.programs.games.lsfg.activate_on_all_games == true then {
            ENABLE_LFSG=1;
            LFSG_MULTIPLIER=2;
          } else {})
          // (if config.mx.programs.games.lsfg.enable == true
            && config.mx.programs.games.lsfg.steam_library_for_lossless_scaling != null then {
            LSFG_DLL_PATH="${config.mx.programs.games.lsfg.steam_library_for_lossless_scaling}/steamapps/common/Lossless Scaling/Lossless.dll";
          } else {});
        };
      };
    };

    users.users = builtins.listToAttrs (map (user: {
      name = user;
      value.extraGroups = [ "gamemode" ];
    }) cfg.gamemode.users);

    environment = {
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        MANGOHUD_CONFIG = "control=mangohud,gpu_list=0,hud_no_margin,legacy_layout=false,horizontal,round_corners=0,background_alpha=0,background_color=000000,font_size=24,text_color=FFFFFF,position=top-center,toggle_hud=Shift_R+F12,no_display,table_columns=1,gpu_text=GPU,gpu_stats,gpu_temp,gpu_power,gpu_color=2E9762,cpu_text=CPU,cpu_stats,cpu_temp,cpu_power,cpu_color=2E97CB,vram,vram_color=AD64C1,ram,ram_color=C26693,battery,battery_color=00FF00,fps,gpu_name,wine,wine_color=EB5B5B,fps_limit_method=late,toggle_fps_limit=Shift_R+F1,fps_limit=0\\,165\\,60\\,30,time";
      };
    };
    environment.systemPackages = [
      pkgs.mangohud
      pkgs.adwsteamgtk
      pkgs.vkbasalt
      pkgs-unstable.goverlay
      mx-game
    ] ++ lib.optional cfg.lsfg.enable lsfg-vk-ui-fhs
    ++ lib.optional cfg.heroic.enable pkgs-unstable.heroic
    ++ lib.optional cfg.lutris.enable pkgs-unstable.lutris
    ++ lib.optional cfg.umu.enable pkgs-unstable.umu;
    hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          package = if cfg.latest-unstable-mesa-driver.enable then pkgs-unstable.mesa else pkgs.mesa;
          package32 = if cfg.latest-unstable-mesa-driver.enable then pkgs-unstable.pkgsi686Linux.mesa else pkgs.pkgsi686Linux.mesa;
        };
    };

    system.activationScripts.vkbasalt-compat = ''
      mkdir -p /usr/share/vulkan/implicit_layer.d
      ln -sf /run/current-system/sw/share/vulkan/implicit_layer.d/vkBasalt.json /usr/share/vulkan/implicit_layer.d/vkBasalt.json

      mkdir -p /usr/lib
      if [ -f "${pkgs.vkbasalt}/lib/libvkbasalt.so" ]; then
        ln -sf "${pkgs.vkbasalt}/lib/libvkbasalt.so" /usr/lib/libvkbasalt.so
      fi
    '';

    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
    '';

    boot = {
      kernelPackages = if cfg.cachyos-kernel.enable then pkgs.cachyosKernels.linuxPackages-cachyos-latest else pkgs.linuxPackages_zen;
      tmp.cleanOnBoot = true;
      kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.max_map_count" = 16777216;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback_centisecs" = 1500;
        "kernel.nmi_watchdog" = 0;
        "kernel.unprivileged_userns_clone" = 1;
        "kernel.printk" = "3 3 3 3";
        "kernel.kptr_restrict" = 2;
        "kernel.kexec_load_disabled" = 1;
      };
    };

    nix.settings.substituters = []
    ++ lib.optionals cfg.cachyos-kernel.enable [ "https://attic.xuyh0120.win/lantian" ];

    nix.settings.trusted-public-keys = []
     ++ lib.optionals cfg.cachyos-kernel.enable [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        var allowedUnits = [
          "docker.service", "docker.socket",
          "ollama.service",
          "open-webui.service",
          "httpd.service", "mysql.service",
          "postgresql.service",
          "cups.service", "cups.socket",
          "teamviewerd.service",
          "libvirtd.service", "libvirtd.socket",
          "virtlogd.service", "virtlogd.socket"
        ];

        if (action.id === "org.freedesktop.systemd1.manage-units" &&
            subject.isInGroup("wheel") &&
            allowedUnits.indexOf(action.lookup("unit")) !== -1) {
          return polkit.Result.YES;
        }

        if (action.id === "org.freedesktop.UPower.PowerProfiles.switch-profile" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    system.activationScripts.steamConfigInject = {
      text = ''
        for user in /home/*; do
          steam_path="$user/.local/share/Steam"
          config_path="$steam_path/config"
          config_file="$config_path/config.vdf"
          mkdir -p "$config_path"
          if [ ! -f "$config_file" ]; then
            cat > "$config_file" <<EOF
        "InstallConfigStore"
        {
        "Software"
        {
          "Valve"
          {
              "Steam"
              {
                  "CompatToolMapping"
                  {
                      "0"
                      {
                          "name"      "GE-Proton"
                          "config"        ""
                          "priority"      "75"
                      }
                  }
                  "ShaderCacheManager"
                  {
                      "EnableShaderBackgroundProcessing"          "1"
                  }
              }
          }
        }
        }
        EOF
            chown -R $(basename "$user"):users "$steam_path"
          fi
        done
      '';
    };
  };
}
