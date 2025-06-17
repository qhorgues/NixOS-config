{ pkgs, ... }:
let
  pname = "kDrive";
  version = "3.6.11.20250415";

  # Téléchargement de l'AppImage de kDrive
  src = pkgs.fetchurl {
    url = "https://download.storage.infomaniak.com/drive/desktopclient/${pname}-${version}-amd64.AppImage";
    sha256 = "sha256-foYqhErZ5G7FKpjvQbdW4wC0WcA+XvMC7Ynphn42W/0=";
  };

  # Code source de l'icône au format SVG (à adapter au besoin)
  iconSvgCode = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 32 32" role="img">
        <path fill="#A2BFFF" fill-rule="evenodd" d="M11.628 1.606c0-1.145 1.139-1.921 2.171-1.48l2.702 1.156c.414.177.733.527.878.96l1.075 3.215c.173.517.591.909 1.11 1.039l11.241 2.813A1.6 1.6 0 0 1 32 10.867v13.425c0 1.08-1.02 1.85-2.028 1.533l-17.238-5.429a1.6 1.6 0 0 1-1.106-1.533z" clip-rule="evenodd" opacity="0.504">

        </path>
        <path fill="#A0BDFF" fill-rule="evenodd" d="M7.709 4.814c0-1.145 1.14-1.921 2.171-1.48l2.702 1.156c.414.177.733.527.878.96l1.075 3.215c.173.517.591.909 1.11 1.039l11.241 2.813a1.6 1.6 0 0 1 1.195 1.559V27.5c0 1.08-1.02 1.85-2.028 1.533L8.815 23.604a1.6 1.6 0 0 1-1.106-1.533z" clip-rule="evenodd" opacity="0.8">

        </path>
        <path fill="#1A47FF" fill-rule="evenodd" d="M3.792 7.54c0-1.145 1.14-1.92 2.171-1.48l2.702 1.157c.414.177.733.526.879.96l1.074 3.214c.173.518.591.91 1.11 1.04l11.241 2.813a1.6 1.6 0 0 1 1.195 1.558v13.425c0 1.079-1.02 1.85-2.028 1.533L4.898 26.33a1.6 1.6 0 0 1-1.106-1.533z" clip-rule="evenodd"></path>
        <path fill="#5287FF" fill-rule="evenodd" d="M.092 15.253c-.422-1.224.676-2.427 1.897-2.08l17.411 4.95c.526.15.938.569 1.088 1.105l3.28 11.749c.17.612-.39 1.174-.985.987L4.546 26.22a1.58 1.58 0 0 1-1.017-.999z" clip-rule="evenodd">

        </path>
    </svg>
  '';

  # Construction d'un package complet qui intègre le binaire, l'icône et le fichier desktop
  kdriveApp = pkgs.stdenv.mkDerivation {
    name = "kdrive-${version}";
    buildInputs = [ pkgs.appimage-run ];
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/scalable/apps

      # Création du script de lancement dans bin/
      cat > $out/bin/kdrive <<EOF
#!/bin/sh
exec ${pkgs.appimage-run}/bin/appimage-run ${src} "\$@"
EOF
      chmod +x $out/bin/kdrive

      # Création du fichier de l'icône SVG à partir de son code source inline
      cat > $out/share/icons/hicolor/scalable/apps/kdrive.svg <<EOF
${iconSvgCode}
EOF

      # Création du fichier .desktop pour l'intégration dans le menu
      cat > $out/share/applications/kdrive.desktop <<EOF
[Desktop Entry]
Name=kDrive
Comment=Accédez à votre compte kDrive
Exec=$out/bin/kdrive --synthesis %U
Icon=kdrive
Terminal=false
Type=Application
Categories=Network;
EOF
    '';
  };
in
{
  environment.systemPackages = [ kdriveApp ];

  systemd.user.services."kdrive" = {
    description = "Lancement de kDrive AppImage";
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${kdriveApp}/bin/kdrive";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
}
