{ lib
, runCommand
, writeText
, makeWrapper
, python3
, glib
, displays ? [ ]
}:

let
  pythonEnv = python3.withPackages (ps: [ ps.pygobject3 ]);

  defaultsJson = writeText "vd-defaults.json" (builtins.toJSON (map (d: {
    output = d.videoOutput;
    width = d.width;
    height = d.height;
    refresh = d.refreshRate;
  }) displays));

  mkBin = name: subcmd: runCommand name {
    nativeBuildInputs = [ makeWrapper ];
  } ''
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/${name} \
      --add-flags "${./display-switch.py} ${subcmd}" \
      --add-flags "--defaults ${defaultsJson}" \
      --prefix GI_TYPELIB_PATH : "${glib}/lib/girepository-1.0"
  '';
in
{
  activate = mkBin "activate-virtual-display" "activate";
  restore = mkBin "restore-display" "restore";
}
