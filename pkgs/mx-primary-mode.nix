{ runCommand
, makeWrapper
, python3
, glib
}:

let
  pythonEnv = python3.withPackages (ps: [ ps.pygobject3 ]);
in
runCommand "mx-primary-mode" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  makeWrapper ${pythonEnv}/bin/python3 $out/bin/mx-primary-mode \
    --add-flags "${../lib/primary-mode.py}" \
    --prefix GI_TYPELIB_PATH : "${glib}/lib/girepository-1.0"
''
