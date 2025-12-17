{ lib, pkgs }:

appId:
  lib.hm.dag.entryAfter ["flatpak"]
    ''
      if ! ${pkgs.flatpak}/bin/flatpak list --user | ${pkgs.gnugrep}/bin/grep -q "${appId}"; then
        ${pkgs.flatpak}/bin/flatpak add --user -y flathub ${appId}
      fi
    ''
