{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "Proton CachyOS",
  version ? "11.0-20260602-slr"
}:
let
  tag = "cachyos-${version}";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos-bin";
  inherit version;

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/${tag}/proton-cachyos-${version}-x86_64.tar.xz";
    hash = "sha256-m/B+WBVJZBpLUvzZZwJ4hGfjbzmohP7TBhfVt5bCzNQ=";
  };


  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "proton-cachyos-${version}-x86_64" "${steamDisplayName}"
  '';

  /*
    We use the created releases, and not the tags, for the update script as nix-update loads releases.atom
    that contains both. Sometimes upstream pushes the tags but the Github releases don't get created due to
    CI errors. Last time this happened was on 8-33, where a tag was created but no releases were created.
    As of 2024-03-13, there have been no announcements indicating that the CI has been fixed, and thus
    we avoid nix-update-script and use our own update script instead.
    See: <https://github.com/NixOS/nixpkgs/pull/294532#issuecomment-1987359650>
  */
  passthru.updateScript = writeScript "update-proton-cachyos" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    repo="https://api.github.com/repos/CachyOS/proton-cachyos/releases"
    version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
    update-source-version proton-cachyos-bin "$version"
  '';

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
