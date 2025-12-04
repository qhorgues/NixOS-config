{ lib
, pkgs
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
stdenv.mkDerivation rec {
  pname = "gnome-ext-hanabi";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "jeffshee";
    repo = "gnome-ext-hanabi";
    rev = "gnome-49";
    hash = "sha256-+CpQm4IQPOpmVrOA9r37UVl6gBk+di8+aBp8DqkjvJk=";
  };
  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    gettext
  ];
  buildInputs = with pkgs; [
    glib
    gjs
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # Remplacer le script postinstall par un vrai script bash qui ne fait rien
  postPatch = ''
    cat > build-aux/meson-postinstall.sh << 'EOF'
#!${pkgs.bash}/bin/bash
exit 0
EOF
    chmod +x build-aux/meson-postinstall.sh
    find . -type f -name "*.js" -exec sed -i 's|/usr/bin/env gjs|${pkgs.gjs}/bin/gjs|g' {} \;

    find . -type f -name "*.js" -exec sed -i "s|'gjs'|'${pkgs.gjs}/bin/gjs'|g" {} \;
  '';

  # Déplacer et compiler les schemas dans le répertoire de l'extension
  postInstall = ''
    extensionDir="$out/share/gnome-shell/extensions/${uuid}"

    # Déplacer le schema XML dans le répertoire schemas de l'extension
    if [ -d "$out/share/glib-2.0/schemas" ]; then
      mkdir -p "$extensionDir/schemas"
      mv "$out/share/glib-2.0/schemas/"*.xml "$extensionDir/schemas/"
      rmdir "$out/share/glib-2.0/schemas"
      rmdir "$out/share/glib-2.0" 2>/dev/null || true

      # Compiler le schema
      ${glib.dev}/bin/glib-compile-schemas "$extensionDir/schemas/"
    fi
  '';

  passthru = {
    extensionUuid = uuid;
  };

  meta = with lib; {
    description = "Hanabi GNOME Shell extension (fireworks animation)";
    homepage = "https://github.com/jeffshee/gnome-ext-hanabi";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
