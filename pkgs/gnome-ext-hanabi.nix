{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, glib
, gettext
}:

let
  uuid = "hanabi-extension@jeffshee.github.io";
in
stdenv.mkDerivation {
  pname = "gnome-ext-hanabi";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jeffshee";
    repo = "gnome-ext-hanabi";
    rev = "gnome-48";
    sha256 = "sha256-Ks+p8geHkzSc2z51GOiugLDqxy8lgNhF/2o3Pc/a9VU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    glib
  ];

  # Le script original installe dans ~/.local/share/gnome-shell/extensions
  # mais pour Nix on installe dans $out/share/gnome-shell/extensions
  mesonFlags = [
    "--prefix=${placeholder "out"}"
  ];

  # Remplacer le postinstall par un script vide
  preConfigure = ''
    echo '#!/bin/sh' > build-aux/meson-postinstall.sh
    echo 'exit 0' >> build-aux/meson-postinstall.sh
    chmod +x build-aux/meson-postinstall.sh
    '';

  installPhase = ''
    ninja -C .build install
    # Déplacer l’extension dans le bon répertoire
    mkdir -p $out/share/gnome-shell/extensions
    mv $out/share/gnome-shell/extensions/${uuid} \
       $out/share/gnome-shell/extensions/
  '';

  extensionUuid = uuid;

  meta = with lib; {
    description = "Hanabi GNOME Shell extension (fireworks animation)";
    homepage = "https://github.com/jeffshee/gnome-ext-hanabi";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
