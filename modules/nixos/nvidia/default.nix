{ nixos-hardware, pkgs, config, lib }:

with lib;
let
  cfg = config.winter.nvidia;
in
{
  imports = [
    ./nvidia-standby.nix
  ];

  options.winter.nvidia = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvidia support";
    };
    laptop = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvidia laptop management";
    };
    card-model = lib.mkOption {
      type = types.string;
      default = null;
      description = "configuration for old gtx nvidia graphic card";
    };
  };

  config = lib.mkIf cfg.enable {

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = !cfg.gtx;
      nvidiaSettings = true;
      modesetting.enable = true;
      prime = {
        intelBusId = optionalAttrs (cfg.intelBusId != null) cfg.intelBusId;
        nvidiaBusId = optionalAttrs (cfg.nvidiaBusId != null) cfg.nvidiaBusId;
        amdgpuBusId = optionalAttrs (cfg.amdBusId != null) cfg.amdgpuBusId;
      };
      dynamicBoost.enable = cfg.laptop;
      powerManagement.enable = cfg.laptop;
    };

    lib.mkMerge [
      (if cfg.laptop then {
        imports = [
          nixos-hardware.nixosModules.common-gpu-nvidia-prime
        ];
      } else {
        imports = [
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        ];
      })
      (if cfg.gtx.enable then {
        hardware.nvidia.open = false;
        boot.kernelPackages = pkgs.linuxPackages;
        hardware.nvidia.powerManagement.enable = true;
        hardware.nvidia.modesetting.enable = true;
      } else {})
    ]
  };
}
