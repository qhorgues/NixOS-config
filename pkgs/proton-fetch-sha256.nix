{ pkgs ? import <nixpkgs> { } }:

let
  reexecJq = ''
    command -v jq >/dev/null 2>&1 || exec ${pkgs.nix}/bin/nix \
      --extra-experimental-features 'nix-command flakes' \
      shell nixpkgs#jq --command "$0" "$@"
  '';

  prefetchFn = ''
    prefetch() {
      local url="$1"
      nix --extra-experimental-features 'nix-command flakes' \
        store prefetch-file --unpack --name source --json "$url" \
        | jq -r .hash
    }

    emit() {
      local arch="$1" url="$2" hash
      if hash=$(prefetch "$url" 2>/dev/null); then
        printf '%-8s %s\n' "$arch" "$hash"
      else
        printf '%-8s <indisponible: %s>\n' "$arch" "$url" >&2
        return 1
      fi
    }
  '';
in
{
  proton-ge-hash = pkgs.writeShellScriptBin "proton-ge-hash" ''
    set -uo pipefail
    ${reexecJq}

    [ $# -eq 1 ] || { echo "usage: proton-ge-hash <version>   # ex: 11-6" >&2; exit 2; }
    version="$1"
    base="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton''${version}"

    ${prefetchFn}

    rc=0
    emit x86_64  "''${base}/GE-Proton''${version}-x86_64.tar.gz"  || rc=1
    emit aarch64 "''${base}/GE-Proton''${version}-aarch64.tar.gz" || rc=1
    exit $rc
  '';

  proton-cachyos-hash = pkgs.writeShellScriptBin "proton-cachyos-hash" ''
    set -uo pipefail
    ${reexecJq}

    [ $# -eq 1 ] || { echo "usage: proton-cachyos-hash <version>   # ex: 11.0-20260703-slr" >&2; exit 2; }
    version="$1"
    base="https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-''${version}"

    ${prefetchFn}

    rc=0
    emit x86_64 "''${base}/proton-cachyos-''${version}-x86_64.tar.xz" || rc=1
    emit arm64  "''${base}/proton-cachyos-''${version}-arm64.tar.xz"  || rc=1
    exit $rc
  '';
}
