# NixOS-config — hosts & Home Manager

Personal NixOS configuration: host definitions and a Home Manager profile.

Everything system-side comes from [**mxpkgs**](https://github.com/Modulix-OS/mxpkgs) (ModulixOS),
consumed through `mxpkgs.lib.modulixosSystem`. `nixpkgs` follows `mxpkgs/nixpkgs`, so both evaluate
against a single nixpkgs.

## Repository structure

```
.
├── flake.nix                → inputs, the shared `common` module, nixosConfigurations
├── hosts/
│   ├── fw-laptop-16/        → Framework 16 (AMD, LUKS root, LLM, Sunshine, gaming)
│   └── desktop-acer-n50/    → Acer N50 (NVIDIA Pascal, GNOME, gaming)
├── home/quentin/            → shared Home Manager profile, imported by each host
├── secrets/ + secrets.nix   → agenix
└── .github/workflows/       → nightly flake.lock update
```

## Flake outputs

| Output                                 | Description                                   |
| -------------------------------------- | --------------------------------------------- |
| `nixosConfigurations.fw-laptop-16`     | Framework Laptop 16                           |
| `nixosConfigurations.desktop-acer-n50` | Acer N50 desktop (hostname `desktop-quentin`) |

That is the whole output set: the Home Manager profile lives in `home/quentin` and is imported by
path, not published as a module.

## How a host is wired

`mkHost` in `flake.nix` calls `mxpkgs.lib.modulixosSystem`, which already injects
`home-manager.nixosModules.default`, `mxpkgs/modulixos` and `mxpkgs/modules`. On top of that it adds:

- `agenix.nixosModules.default` — mxpkgs carries no secret management of its own
- an inline `common` module defined in `flake.nix` — `age.identityPaths`, the agenix CLI, OpenSSH
  with the firewall closed, and the overlay adding personal packages to `pkgs`. It lives there
  rather than in a file because every line of it comes from this flake's own inputs
- `hosts/<name>/configuration.nix`

## Home Manager

Each host points at its own user file and leaves `homeModule` unset:

```nix
mx.programs.home-manager = {
  enable = true;
  users.quentin.configPath = ./quentin.nix;
};
```

`hosts/<name>/quentin.nix` imports the shared profile itself:

```nix
imports = [
  ../../home/quentin
  ./zed-remote-folder.nix
];
```

so per-host tweaks stay in the host directory and everything common stays in `home/quentin`.

mxpkgs passes itself to Home Manager as the `modulixos-config` extra argument, which is how
`modulixos-config.packages.<system>.*` and `modulixos-config.lib.*` resolve inside `home/quentin` and
the hosts' `quentin.nix`.

## Build

```bash
sudo nixos-rebuild switch --flake .#fw-laptop-16
sudo nixos-rebuild switch --flake .#desktop-acer-n50
```

`mx.update.flake_path` in each host's `quentin.nix` points at this repository, so the `nix-update` and
`nix-clean-boot` helpers rebuild the right flake. Update it if you move the checkout.

## Secrets (agenix)

`secrets.nix` maps each encrypted file to the public keys allowed to decrypt it. Decryption uses the
**host** SSH key (`/etc/ssh/ssh_host_ed25519_key`), set by the `common` module in `flake.nix`.

```bash
nix run github:ryantm/agenix -- -e secrets/<host>/<secret>.age
nix run github:ryantm/agenix -- -r          # re-key after changing the key list
```

A host declares the secret and reads the decrypted path at runtime:

```nix
age.secrets.huggingface-token.file = ../../secrets/shared/huggingface-token.age;
mx.services.llm.huggingfaceTokenFile = config.age.secrets.huggingface-token.path;
```

## Packages

Most packages come from mxpkgs, reached through the `modulixos-config` argument Home Manager receives
(mxpkgs passes itself):

| Reference                                                    | Provides                                                                                                                                                                                                         |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `modulixos-config.packages.<system>.*`                       | `clean-dir`, `nix-clean`, `nix-latest-update`, `modulix-icon`, `texstudio`, `gnomeExtensions.hanabi`, …                                                                                                          |
| `modulixos-config.lib.mkNixUpdate` / `.mkNixCleanBoot`       | used by `home/quentin/core/flake-script.nix`. Both scripts bake the flake location into themselves, so mxpkgs exports them as builders taking `{ pkgs, flake_path, flake_config }` rather than as plain packages |
| `modulixos-config.lib.mkGameConfigSwitcher` / `.igpu-launch` | used by `hosts/fw-laptop-16/quentin.nix`                                                                                                                                                                         |

Packages that are personal rather than part of ModulixOS stay here instead, added to `pkgs` by an
overlay in the `common` module of `flake.nix` so they are reachable as `pkgs.<name>` from Home Manager too
(mxpkgs sets `home-manager.useGlobalPkgs`):

| Package      | Input                                | Used by                   |
| ------------ | ------------------------------------ | ------------------------- |
| `pkgs.coe33` | `github:qhorgues/CO-E33-Save-Editor` | both hosts' `quentin.nix` |

## Option reference

System options (`mx.*` on the NixOS side) are documented in mxpkgs. The options declared by _this_
repository are the Home Manager ones in `home/quentin`:

| Option                                                        | Description                                                                                                                                                                                                                                                                    |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `mx.update.flake_path` / `.flake_config`                      | flake directory and configuration name used by `nix-update`                                                                                                                                                                                                                    |
| `mx.auto-update.enable`                                       | inert — the timer consuming it is commented out                                                                                                                                                                                                                                |
| `mx.services.flatpak.enable`                                  | user Flatpak installation, Flathub remote, Flatseal                                                                                                                                                                                                                            |
| `mx.desktop-environment.gnome.connection` / `.live-wallpaper` | GNOME Connections, Hanabi video wallpaper                                                                                                                                                                                                                                      |
| `mx.programs.*`                                               | `audio-enhancer`, `cryptomator`, `discord`, `element`, `firefox`, `git`, `graphism.{gimp,inkscape,krita}`, `kdrive`, `linux-base-tools`, `office.{latex,libre-office,onlyoffice}`, `ssh`, `thunderbird`, `video-downloader`, `vim`, `vscode`, `winboat`, `zed-editor`, `dev.*` |

The profile is personal: it hardcodes a git identity (`home/quentin/dev/git.nix`) and SSH hosts
(`home/quentin/ssh/ssh-config.nix`).

## CI

`.github/workflows/update-flake.yml` runs `nix flake update` nightly, opens a PR, and merges it after
a delay when `flake.lock` is the only changed file. `gitlab-ci.yml` is the GitLab equivalent and is
inactive as committed (rename it to `.gitlab-ci.yml` to enable it).

## License

See [LICENSE](LICENSE).
