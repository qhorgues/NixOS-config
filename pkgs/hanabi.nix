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
    rev = "main";
    hash = "sha256-oTXfNluKBX5PFxu6H3P0iB6CZFmljWWTrASWf40QZe8=";
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
    schemas=$(echo "$out/share/gsettings-schemas/"*/glib-2.0/schemas)

    makeWrapper ${gjs}/bin/gjs "$ext/hanabi-gjs" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0" \
      --prefix GSETTINGS_SCHEMA_DIR : "$schemas"

    substituteInPlace "$ext/extension.js" \
      --replace-fail 'argv.push("gjs", "-m",' "argv.push(\"$ext/hanabi-gjs\", \"-m\","

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
