{ config, pkgs, pkgs-unstable,  lib, ... }:

let
  cfg = config.winter.services.llm;
  # open-webui-shortcut = pkgs.makeDesktopItem {
  #   name = "Open WebUI";
  #   desktopName = "IA local";
  #   exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:8080";
  #   icon = "wechat";
  #   comment = "Acceder a l'ia locale";
  #   categories = [ "Utility" ];
  # };
in
{
  options.winter.services.llm = {
    enable = lib.mkEnableOption "Enable local LLM service";
  };
  config = lib.mkIf cfg.enable {
    winter.hardware.gpu.enable-acceleration = true;

    environment.systemPackages = [
      # open-webui-shortcut
      pkgs.newelle
    ];


    services.open-webui = {
      package = pkgs.open-webui;
      enable = true;
      port = 8080;
    };

    services.ollama = {
      enable = true;
      package =
      (if config.winter.hardware.gpu.acceleration == "cuda" then
        pkgs-unstable.ollama-cuda
      else if config.winter.hardware.gpu.acceleration == "rocm" then
        pkgs-unstable.ollama-rocm
      else if config.winter.hardware.gpu.acceleration == "intel" then
        pkgs-unstable.ollama-vulkan
      else if config.winter.hardware.gpu.acceleration == "cpu" then pkgs-unstable.ollama-cpu
      else pkgs-unstable.ollama
      );
      loadModels = [ "qwen3.5:9b" ];
      acceleration = config.winter.hardware.gpu.acceleration; # use cuda if nvidia, rocm if amd, and cpu only otherwise
    };
  };
}
