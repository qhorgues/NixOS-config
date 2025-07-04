{ pkgs, ... }:

pkgs.python312Packages.buildPythonPackage rec {
  pname    = "gaphas";
  version  = "3.1.4";
  src      = pkgs.fetchPypi {
    inherit pname version;
    sha256   = "sha256-9kDghCuMmJCNjJJZR44hrDvtJA+nrD/lYa4riMPLgyQ=";
  };
  propagatedBuildInputs = with pkgs.python312Packages; [
    pycairo
  ];
  # pas de tests par défaut, pour accélérer la construction
  doCheck  = false;
  meta     = with pkgs.lib; {
    description = "GTK+ based diagramming widget (gaphas 3.x)";
    homepage    = "https://github.com/gaphas/gaphas";
    license     = licenses.asl20;
  };
}
