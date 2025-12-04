{ lib
, stdenv
, fetchFromGitHub
, python3
, gnumake
, gcc-arm-embedded
, avrdude
, dfu-util
, dfu-programmer
, teensy-loader-cli
, bootloadhid
, wb32-dfu-updater
, pkgsCross
}:

let
  qmk-cli = python3.pkgs.buildPythonApplication rec {
    pname = "qmk";
    version = "1.1.5";
    format = "pyproject";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Lv48dSIwxrokuHGcO26FpWRL+PfQ3SN3V+2pt7fmCxE=";
    };

    nativeBuildInputs = with python3.pkgs; [
      setuptools
      wheel
    ];

    propagatedBuildInputs = with python3.pkgs; [
      appdirs
      argcomplete
      colorama
      dotty-dict
      hid
      hjson
      jsonschema
      milc
      pygments
      pyserial
      pyusb
      pillow
    ];

    # Désactiver les tests car ils nécessitent un environnement QMK complet
    doCheck = false;
  };
in
stdenv.mkDerivation rec {
  pname = "framework-qmk-firmware";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "FrameworkComputer";
    repo = "qmk_firmware";
    rev = "v${version}";
    sha256 = "sha256-xGk+vWCgDdb3G0BU4Gm95Nx43JoVeoUhwWKN9Lg2n2w=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qmk-cli
    gnumake
    python3
  ];

  buildInputs = [
    gcc-arm-embedded
    avrdude
    dfu-util
    dfu-programmer
    teensy-loader-cli
    bootloadhid
    wb32-dfu-updater
    pkgsCross.avr.buildPackages.binutils
    pkgsCross.avr.buildPackages.gcc
    pkgsCross.avr.libcCross

  ];

  postPatch = ''
    patchShebangs .
  '';

  # Définir QMK_HOME pour que qmk-cli trouve les fichiers
  preBuild = ''
    export QMK_HOME=$PWD
  '';

  buildPhase = ''
    runHook preBuild

    qmk compile -kb framework/iso -km default
    qmk compile -kb framework/numpad -km default

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/qmk
    cp -r * $out/share/qmk

    mkdir -p $out/firmware
    find . \( -name "*.hex" -o -name "*.bin" -o -name "*.uf2" \) -exec cp {} $out/firmware/ \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Framework Laptop 16 QMK firmware (v${version})";
    homepage = "https://github.com/FrameworkComputer/qmk_firmware";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
