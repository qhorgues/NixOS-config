{ config, pkgs, pkgs-unstable, lib, ... }:

let
  cfg = config.winter.programs.games;
  cgpu = config.winter.hardware.gpu;
  lsfg-vk = pkgs.callPackage ../../../pkgs/lsfg-vk.nix { };
  # lsfg-vk-ui = pkgs.callPackage ../../../pkgs/lsfg-vk-ui.nix { };
in
{

  options.winter.programs.games = {
    enable = lib.mkEnableOption "Enable Game config";

    force-fsr4-for-rdna3 = lib.mkEnableOption "Force FSR4 on AMD 7000 series";

    lsfg = {
      enable = lib.mkEnableOption "Enable Losseless Scaling (required Lossless scaling app on Steam)";

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
        extraPackages = []
        ++ lib.optional config.winter.programs.games.lsfg.enable lsfg-vk;
        extraCompatPackages = [
          pkgs-unstable.proton-ge-bin
        ];
        package = pkgs.steam.override {
          extraEnv = {
            TZ = ":/etc/localtime";
            MANGOHUD = true;
            PROTON_ENABLE_WAYLAND=true;
            # PROTON_NO_D3D12=true;

            PROTON_FSR4_UPGRADE = cgpu.vendor == "amdgpu"
                                  && cgpu.generation == "rdna4";
            PROTON_FSR4_RDNA3_UPGRADE = cgpu.vendor == "amdgpu"
                                        && cgpu.generation == "rdna3"
                                        && cfg.force-fsr4-for-rdna3;
            PROTON_FSR3_UPGRADE = cgpu.generation == "rdna3"
                                  && (!cfg.force-fsr4-for-rdna3);
            PROTON_DLSS_UPGRADE = cgpu.vendor == "nvidia";
            PROTON_XESS_UPGRADE = cgpu.vendor == "intel"
                                  || (cgpu.vendor == "amdgpu"
                                      && cgpu.generation != "rdna4");
          } //
          (if config.winter.programs.games.lsfg.enable == true then {
            VK_LAYER_PATH= "${lsfg-vk}/share/vulkan/explicit_layer.d";
            ENABLE_LFSG=1;
            LSFG_LEGACY=1;
            LFSG_MULTIPLIER=2;
          } else {})
          // (if config.winter.programs.games.lsfg.enable == true
            && config.winter.programs.games.lsfg.steam_library_for_lossless_scaling != null then {
            LSFG_DLL_PATH="${config.winter.programs.games.lsfg.steam_library_for_lossless_scaling}/steamapps/common/Lossless Scaling/Lossless.dll";
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
    environment.systemPackages = with pkgs; [
      mangohud
      adwsteamgtk
      vkbasalt
      pkgs-unstable.goverlay
    ];
    hardware = {
        graphics = {
          enable = true;
          enable32Bit = true;
          package = pkgs.mesa;
          package32 = pkgs.pkgsi686Linux.mesa;
        };
    };

    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}="bfq"
    '';

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.kernel.sysctl = {
      # "kernel.split_lock_mitigate" = 0;
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
