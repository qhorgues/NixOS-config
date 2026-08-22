{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  glib,
  gobject-introspection,
  atk,
  cairo,
  graphene,
  gsettings-desktop-schemas,
  lcms2,
  libGL,
  libxkbcommon,
  pixman,
  wayland,
  libx11,
  libxfixes,
  libxi,
  mutter,
}:

stdenv.mkDerivation {
  pname = "gnome-rounded-blur";
  version = "1.0.0-unstable-2026-08-09";

  src = fetchFromGitHub {
    owner = "kancko";
    repo = "gnome-rounded-blur";
    rev = "f3bfcc796e1214c1e1d4287ee35cb132ad8133f0";
    hash = "sha256-MBeb0/Drt0UQ/K8UaW93ae9OaV3L5nhFZB2tPwj47co=";
  };

  postPatch = ''
    mutter_api=$(basename "$(ls ${mutter.dev}/lib/pkgconfig/libmutter-*.pc)" .pc)
    mutter_api=''${mutter_api#libmutter-}

    substituteInPlace meson.build \
      --replace-fail "mutter_api_version = '18'" "mutter_api_version = '$mutter_api'" \
      --replace-fail "mutter_req = '>= 50.0'" "mutter_req = '>= ${lib.versions.major mutter.version}.0'" \
      --replace-fail "dependency('libmutter-18')" "dependency('libmutter-' + mutter_api_version)"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
    gobject-introspection
  ];

  buildInputs = [
    glib
    mutter
    atk
    cairo
    graphene
    gsettings-desktop-schemas
    lcms2
    libGL
    libxkbcommon
    pixman
    wayland
    libx11
    libxfixes
    libxi
  ];

  postFixup = ''
    patchelf --add-rpath "$(echo ${mutter}/lib/mutter-*)" "$out/lib/libblur-effect-1.0.so.1.0.0"
  '';

  meta = {
    description = "Blur.BlurEffect with corner radius support for GNOME Shell extensions";
    homepage = "https://github.com/kancko/gnome-rounded-blur";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
