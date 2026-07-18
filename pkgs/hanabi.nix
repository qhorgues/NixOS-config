{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  meson,
  ninja,
  glib,
  gettext,
  nodejs,
  npmHooks,
  gobject-introspection,
  wrapGAppsHook4,
  gjs,
  gtk4,
  libadwaita,
  gst_all_1,
  withClapper ? false,
  clapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-hanabi";
  version = "0-unstable-2025-01-01";

  src = fetchFromGitHub {
    owner = "jeffshee";
    repo = "gnome-ext-hanabi";
    rev = "typescript";
    hash = "sha256-GPkmnmwCahP9tm3MeMhE06efel1RmQBM3Sf2ay0hhMI=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-npm-deps";
    hash = "sha256-uYhpa0MdWgkvX9XRk6lHR3ShoDtTKfrP9ZFsIxv34X8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    glib
    gettext
    nodejs
    npmHooks.npmConfigHook # peuple le cache npm offline (npm ci)
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    gtk4
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-rs # gtk4paintablesink (sink par défaut)
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi
  ] ++ lib.optional withClapper clapper;

  dontWrapGApps = true;

  postPatch = ''
    patchShebangs build-aux/meson-postinstall.sh
  '';

  preConfigure = ''
    npm run build
  '';

  postFixup = ''
    ext=$out/share/gnome-shell/extensions/${finalAttrs.passthru.extensionUuid}
    r=$ext/renderer/renderer.js
    schemas=$(echo "$out/share/gsettings-schemas/"*/glib-2.0/schemas)

    mv "$r" "$r.mjs"
    makeWrapper ${gjs}/bin/gjs "$r" \
      --add-flags "-m $r.mjs" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0" \
      --prefix GSETTINGS_SCHEMA_DIR : "$schemas"

    ln -s "$schemas" "$ext/schemas"
  '';

  passthru.extensionUuid = "hanabi-extension@jeffshee.github.io";

  meta = {
    description = "Live wallpaper for GNOME";
    homepage = "https://github.com/jeffshee/gnome-ext-hanabi";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
