{ pkgs ? import <nixpkgs> {}, nix-latest-update, flake_path, flake_config }:

pkgs.writeShellScriptBin "nix-update" ''
    cd ${flake_path}
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
      echo "Le dépôt contient des modifications non commités. Abandon."
      exit 1
    fi

    ${pkgs.nix}/bin/nix flake update --flake ${flake_path}

    ${pkgs.git}/bin/git add flake.lock > /dev/null 2>&1
    ${pkgs.git}/bin/git commit -m "update" > /dev/null 2>&1


    if sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake_path}\#${flake_config}; then
      ${pkgs.git}/bin/git push > /dev/null 2>&1
      echo "✅ Mise à jour avec succès"
      ${nix-latest-update}/bin/nix-latest-update
      exit 0
    else
      echo "Échec de la mise à jour"
      ${pkgs.git}/bin/git reset --hard HEAD~1 > /dev/null 2>&1
      exit 1
    fi
''
