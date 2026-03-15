{ lib, pkgs, enableApp ? false }:

appId:
  if enableApp then
    lib.hm.dag.entryAfter ["flatpak"]
      ''
        if ! ${pkgs.flatpak}/bin/flatpak list --user | ${pkgs.gnugrep}/bin/grep -q "${appId}"; then
          ${pkgs.flatpak}/bin/flatpak install --user -y flathub ${appId}
        fi
      ''
  else
  lib.hm.dag.entryAfter ["flatpak"]
    ''
      if ${pkgs.flatpak}/bin/flatpak list --user | ${pkgs.gnugrep}/bin/grep -q "${appId}"; then
        ${pkgs.flatpak}/bin/flatpak uninstall --user -y ${appId}
      fi
    ''
