{ pkgs, config, lib, ... }:

let
  useCuda = lib.mkBool config.hardware.nvidia.enable;
  useRocm = config.hardware.amd.enable;
in
{
  environment.systemPackages = [
    pkgs.ollama
  ];


  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b" ];
    acceleration = if useCuda then "cuda" else if useRocm then "rocm" else false;
  };
}
