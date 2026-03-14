{ config, pkgs, pkgs-unstable,  lib, ... }:

let
  cfg = config.mx.services.llm;
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
  options.mx.services.llm = {
    enable = lib.mkEnableOption "Enable local LLM service";
    open-webui = {
      enable = lib.mkEnableOption "Enable Open Webui service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for open webui interface";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    mx.hardware.gpu.enable-acceleration = true;

    environment.systemPackages = [
      # open-webui-shortcut
      pkgs.newelle
    ];


    services.open-webui = {
      package = pkgs.open-webui;
      enable = cfg.open-webui.enable;
      port = cfg.open-webui.port;
    };

    services.ollama = {
      enable = true;
      package =
      (if config.mx.hardware.gpu.acceleration == "cuda" then
        pkgs-unstable.ollama-cuda
      else if config.mx.hardware.gpu.acceleration == "rocm" then
        pkgs-unstable.ollama-rocm
      else if config.mx.hardware.gpu.acceleration == "intel" then
        pkgs-unstable.ollama-vulkan
      else if config.mx.hardware.gpu.acceleration == "cpu" then pkgs-unstable.ollama-cpu
      else pkgs-unstable.ollama
      );
      loadModels = [
        "qwen3.5:9b"
        "qwen3-coder-next"
      ];
      acceleration = config.mx.hardware.gpu.acceleration; # use cuda if nvidia, rocm if amd, and cpu only otherwise
    };
  };
}
