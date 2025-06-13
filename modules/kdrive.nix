{ pkgs, ... }:
let
  pname = "kDrive";
  version = "3.6.11.20250415";

  src = pkgs.fetchurl {
    url = "https://download.storage.infomaniak.com/drive/desktopclient/${pname}-${version}-amd64.AppImage";
    sha256 = "sha256-foYqhErZ5G7FKpjvQbdW4wC0WcA+XvMC7Ynphn42W/0=";
  };

  kdriveApp = pkgs.writeShellScriptBin "kdrive" ''
  ${pkgs.appimage-run}/bin/appimage-run ${src} "$@"
  '';
in
{
  environment.systemPackages = [
    kdriveApp
  ];

  systemd.user.services."kDrive" = {
    description = "kDrive AppImage startup";
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${kdriveApp}/bin/kdrive";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
}
