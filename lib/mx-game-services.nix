{ lib, config }:

let
  svc = config.mx.services;

  table = {
    docker = {
      enable = svc.docker.enable;
      units = [ "docker.service" "docker.socket" ];
    };
    llama-cpp = {
      enable = svc.llm.enable;
      units = [ "llama-cpp.service" ];
    };
    open-webui = {
      enable = svc.llm.open-webui.enable;
      units = [ "open-webui.service" ];
    };
    lamp = {
      enable = svc.lamp.enable;
      units = [ "httpd.service" "mysql.service" ];
    };
    postgres = {
      enable = svc.postgresql.enable;
      units = [ "postgresql.service" ];
    };
    printing = {
      enable = svc.printing.enable;
      units = [ "cups.service" "cups.socket" ];
    };
    teamviewer = {
      enable = config.mx.programs.team-viewer.enable;
      units = [ "teamviewerd.service" ];
    };
    vm = {
      enable = svc.vm.enable;
      units = [
        "libvirtd.service"
        "libvirtd.socket"
        "virtlogd.service"
        "virtlogd.socket"
      ];
    };
  };
in
{
  inherit table;

  allUnits = lib.concatMap (e: e.units) (lib.attrValues table);

  enabledUnits = lib.concatMap (e: e.units) (lib.filter (e: e.enable) (lib.attrValues table));
}
