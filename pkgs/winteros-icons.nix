{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "WinterOS-icons";
  version = "1.0";

  src = null; # pas de source externe, on va juste assembler

  buildInputs = [ pkgs.adwaita-icon-theme pkgs.papirus-icon-theme pkgs.hicolor-icon-theme ];
  nativeBuildInputs = [ pkgs.gtk3 ];

  dontUnpack = true;

  installPhase = ''
      outdir=$out/share/icons/WinterOS-icons
      mkdir -p $outdir
      echo "[Icon Theme]
Name=WinterOS-icons
Comment=Adwaita with Papirus fallbacks
Inherits=Papirus,Adwaita,hicolor
Directories=" > $outdir/index.theme
  '';

  meta = with pkgs.lib; {
    description = "Thème d’icônes Adwaita avec icônes d’applications WinterOS";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
