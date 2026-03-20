{ lib
, stdenvNoCC
, adwaita-icon-theme
, papirus-icon-theme
}:

stdenvNoCC.mkDerivation {
  pname = "modulix-icon-theme";
  version = adwaita-icon-theme.version;

  dontUnpack = true;
  dontWrapQtApps = true;   # <-- corrige l'erreur qtbase

  propagatedBuildInputs = [
    adwaita-icon-theme
    papirus-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    THEME_DIR="$out/share/icons/Modulix-OS"
    mkdir -p "$THEME_DIR"

    cp -r ${adwaita-icon-theme}/share/icons/Adwaita/. "$THEME_DIR/"
    chmod -R u+w "$THEME_DIR"

    sed -i 's/^Inherits=.*/Inherits=Papirus,hicolor/' "$THEME_DIR/index.theme"
    sed -i 's/^Name=.*/Name=Modulix-OS/'              "$THEME_DIR/index.theme"

    runHook postInstall
  '';

  meta = {
    description = "Modulix OS icon theme (Adwaita + Papirus fallback)";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
  };
}
