# Modulix-OS — NixOS configuration flake

A modular NixOS configuration published as a **library flake**.

This repository is *not* a drop-in system configuration: it contains no `hosts/` directory and no
`nixosConfigurations` output. Instead it exports a host factory (`lib.make-system`), a set of NixOS
modules, a Home Manager module and a handful of packages, all meant to be consumed from **your own**
host repository.

Everything the modules provide is opt-in through a single option namespace: `mx.*`.

Pinned to `nixpkgs` `nixos-26.05` and `home-manager` `release-26.05`.

## Features

- Single `mx.*` option namespace — every module is imported automatically and gated by its own option
- Host factory `lib.make-system` that wires agenix, Home Manager and all system modules for you
- Gaming stack: Steam, gamescope session, GameMode, MangoHud, Proton-GE + Proton-CachyOS, HDR,
  FSR4/DLSS/XeSS, Lossless Scaling (`lsfg-vk`)
- Local LLM serving: llama.cpp (CUDA / ROCm / Vulkan variant selected from your GPU setting) + Open WebUI
- Virtual displays generated from synthetic EDID blobs, with Sunshine remote desktop integration
- Secrets management with agenix, keyed on the host SSH key
- Optional CachyOS kernel, kernel CVE mitigations, zram, TPM2, Limine with secure boot auto-enroll
- Desktop support for GNOME and LXQt (plus Plasma-specific behaviour, DE not provided)
- Home Manager profile with EasyEffects presets, Firefox policies, Zed/VS Code, kDrive, Flatpak apps

## Repository structure

```
.
├── flake.nix                → Inputs, make-system, modules and packages
├── flake.lock               → Locked dependencies
├── lib/                     → Nix + Python helpers (EDID generation, display switching, GPU launchers)
├── modules/
│   ├── nixos/               → System modules, all auto-imported, gated by mx.*
│   └── home-manager/
│       └── quentin/         → Personal Home Manager profile (exported as homeModules.quentin)
├── pkgs/                    → Custom derivations (6 of them exposed as flake packages)
├── secrets/                 → age-encrypted secrets
├── secrets.nix              → agenix rules (public keys → secret paths)
├── .github/workflows/       → Nightly flake.lock update + delayed auto-merge
├── gitlab-ci.yml            → GitLab equivalent (inactive, see CI section)
└── LICENSE
```

## Flake outputs

| Output | Description |
|---|---|
| `lib.make-system` | Host factory. `{ system ? "x86_64-linux", modules ? [], specialArgs ? {} }` → `nixosSystem` |
| `lib.mkGameConfigSwitcher` | Builds `<game>-config-{igpu,dgpu}` / `<game>-set-{igpu,dgpu}` scripts to swap per-GPU game configs inside a Proton prefix |
| `lib.igpu-launch` | `{ pkgs, igpuId, igpuNumber }` → wrapper forcing a command onto the integrated GPU |
| `nixosModules.modulix-os` | All system modules, for grafting into an existing configuration |
| `nixosModules.home-manager` | Re-export of `home-manager.nixosModules.default` |
| `nixosModules.agenix` | Re-export of `agenix.nixosModules.default` |
| `homeModules.quentin` | The Home Manager profile in `modules/home-manager/quentin` |
| `packages.<system>` | `coe33`, `clean-dir`, `lsfg-vk`, `nix-clean`, `nix-latest-update`, `kiwix` |

There is deliberately no `nixosConfigurations`, `devShells`, `formatter` or `checks` output.

## Usage

### A. `lib.make-system` (recommended)

Create your own flake in a separate repository and add this one as an input:

```nix
{
  inputs = {
    modulix.url = "github:qhorgues/NixOS-config";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, modulix, nixos-hardware, ... }: {
    nixosConfigurations.my-host = modulix.lib.make-system {
      system = "x86_64-linux";           # this is the default, can be omitted
      modules = [
        nixos-hardware.nixosModules.framework-16-7040-amd
        ./hosts/my-host/configuration.nix
        ./hosts/my-host/hardware-configuration.nix
      ];
    };
  };
}
```

`make-system` already injects, so you never list them yourself:

- **modules**: `agenix.nixosModules.default`, `home-manager.nixosModules.default`, and this repo's
  `modules/nixos` (which imports every system module)
- **specialArgs**: `self` (this flake), `inputs`, `pkgs-unstable` (nixpkgs-unstable for your system,
  with `allowUnfree`) and `secretsPath` (this repo's `secrets/` directory)

Anything you pass in `specialArgs` overrides those defaults.

### B. `nixosModules.modulix-os`

Use this when you already have a NixOS configuration and only want to graft the modules in.

> **Caveat:** this output only sets `inputs` and `secretsPath` as module arguments. The `games`,
> `llm` and `home-manager` modules also need `self` and `pkgs-unstable`, so you must supply them
> yourself:

```nix
{ pkgs, ... }:
{
  imports = [ inputs.modulix.nixosModules.modulix-os ];

  _module.args = {
    self = inputs.modulix;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
```

## Host configuration

Because every module is imported automatically, a host file is just options:

```nix
{ ... }:
{
  networking.hostName = "my-host";

  mx = {
    main-user = {
      enable = true;
      userName = "alice";
      userFullName = "Alice Example";
    };

    hardware = {
      framework-fan-ctrl.enable = true;   # Framework laptops only
      cpu = {
        vendor = "amd";                   # intel, amd or null
        generation = null;                # intel iGPU only: modern or legacy
      };
      gpu = {
        vendor = "amd";                   # amd, nvidia, intel or null
        computing = "rocm";               # rocm, cuda, intel, cpu or null
        generation = "rdna3";             # see mx.hardware.gpu.generation below
      };
      ssd.lists = [ "/" "/home" ];        # mountpoints to get noatime/discard
    };

    desktop = {
      environment = "gnome";              # none, gnome, plasma or lxqt
      gnome = {
        scaling = 2;                      # GDM only
        text-scaling = 0.7;               # GDM only
      };
    };

    fonts.enable = true;

    programs.home-manager = {
      enable = true;
      users.alice = {
        configPath = ./alice.nix;
      };
    };
  };
}
```

> **Security note:** `mx.main-user` creates the account with `initialPassword = "1234"`.
> Change it with `passwd` on first login.

Hardware modules for specific machines live in the
[nixos-hardware](https://github.com/NixOS/nixos-hardware) repository.

## Home Manager

Home Manager is wired through `mx.programs.home-manager`, which sets `useGlobalPkgs` and
`useUserPackages`, and passes `qhorgues-config` (this flake), `pkgs-unstable` and `inputs` as
`extraSpecialArgs`. `home.username` and `home.homeDirectory` default to the attribute name and
`/home/<name>`.

```nix
mx.programs.home-manager = {
  enable = true;
  users.alice = {
    configPath = ./alice.nix;    # required — your own Home Manager config
    homeModule = "quentin";      # optional — a name in self.homeModules
  };
};
```

`homeModules.quentin` is a **personal** profile, not a neutral module set. It hardcodes a git
identity (`modules/home-manager/quentin/dev/git.nix`) and five personal SSH hosts
(`modules/home-manager/quentin/ssh/ssh-config.nix`). Unless you want those, leave `homeModule` at
its `null` default and write your own `configPath` file, importing the pieces you need.

A minimal `alice.nix`:

```nix
{ ... }:
{
  mx = {
    update = {
      flake_path = "/home/alice/config";   # directory, not the flake.nix file
      flake_config = "my-host";
    };

    programs = {
      firefox.enable = true;
      linux-base-tools.enable = true;
      dev = {
        enable = true;
        nix = true;
        rust = true;
      };
    };
  };

  home.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };
}
```

## Installation

### 1. Install NixOS

Download the ISO from the [official website](https://nixos.org/download) and write it to a USB drive
with `dd`, [Ventoy](https://www.ventoy.net/en/index.html) or
[BalenaEtcher](https://www.balena.io/etcher/).

After installing, reboot immediately into the firmware setup.

### 2. Put secure boot in setup mode

### 3. Create and enroll secure boot keys

Boot into your fresh NixOS install, then:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl -- create-keys
sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl -- enroll-keys --microsoft --firmware-builtin
```

`mx.bootloader.enable` defaults to `true` and installs Limine with secure boot auto-enroll, keeping
10 generations.

### 4. Create your host repository

```bash
mkdir -p ~/config/hosts/my-host
cd ~/config
git init
cp /etc/nixos/hardware-configuration.nix hosts/my-host/hardware-configuration.nix
```

Write `flake.nix` as shown in [Usage A](#a-libmake-system-recommended) and
`hosts/my-host/configuration.nix` as shown in [Host configuration](#host-configuration).

### 5. Build

```bash
sudo nixos-rebuild switch --flake ~/config#my-host
```

## Option reference — NixOS

### `mx.mode` / `mx.programs._studio`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.mode.server.enable` | bool | `false` | Server mode. Disables filesystem extras, nix-ld, network, sound, bluetooth, iOS connection and GPU acceleration |
| `mx.programs._studio.enable` | bool | `false` | Internal. Pulls in the media kernel configuration; set automatically by the OBS module |

### `mx.core`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.core.network.enable` | bool | `true` | NetworkManager and related networking |
| `mx.core.network.security-mode` | bool | `false` | MAC randomization, no hostname leak, disables mDNS/LLMNR/avahi |
| `mx.core.sound.enable` | bool | `true` | PipeWire, low latency (48 kHz / 256 quantum) |
| `mx.core.networking.dnsmasq.nonPrivate` | bool | `true` | Restrict access to non-private DNS. Setting it to `false` **adds** OpenDNS/Cloudflare/Google resolvers |

dnsmasq is always enabled and NetworkManager is configured with `dns = dnsmasq`.

### `mx.bootloader` / `mx.kernel`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.bootloader.enable` | bool | `true` | Limine bootloader with secure boot auto-enroll, 10 generations |
| `mx.kernel.cachyos-kernel.enable` | bool | `false` | Use the CachyOS kernel. Adds the `attic.xuyh0120.win` substituter. **Currently broken**, see below |
| `mx.kernel.cachyos-kernel.package` | package | `pkgs.cachyosKernels.linuxPackages_cachyos` | Kernel package to use. **Currently broken** — that attribute does not exist |

> `mx.kernel.cachyos-kernel.enable = true` fails to evaluate. The overlay provides
> `linuxPackages-cachyos-{bore,latest,lts,server,rt-bore}` (and matching `linux-cachyos-*` kernels),
> not `linuxPackages_cachyos`. The module is also self-inconsistent: `boot.kernelPackages` wraps the
> value in `linuxPackagesFor` (which expects a kernel) while `boot.zfs.package` reads
> `.zfs_cachyos` off it (which only exists on a packages set), and `types.package` rejects a packages
> set outright. Fixing it means changing the default, the type and the `boot.kernelPackages` line
> together.

### `mx.security.mitigations`

All default to `true`.

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.security.mitigations.enable` | bool | `true` | Master switch for the mitigations below |
| `mx.security.mitigations.blacklistDirtyFrag` | bool | `true` | Blacklist `esp4`/`esp6` (CVE-2026-43284) and `rxrpc` (CVE-2026-43500) |
| `mx.security.mitigations.blacklistCopyFail` | bool | `true` | Blacklist `algif_aead` (CVE-2026-31431) |
| `mx.security.mitigations.blacklistFragnesia` | bool | `true` | Blacklist `ipcomp4`/`ipcomp6` (CVE-2026-46300) |
| `mx.security.mitigations.mitigateSshKeysignPwn` | bool | `true` | `kernel.yama.ptrace_scope = 2` (CVE-2026-46333) |

### `mx.hardware`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.hardware.cpu.vendor` | `intel`, `amd` or null | `null` | CPU constructor |
| `mx.hardware.cpu.generation` | `modern`, `legacy` or null | `null` | Intel iGPU era: `modern` (Gen8+/Broadwell and newer, `iHD` driver) or `legacy` (`i965`). Ignored on AMD CPUs, `null` behaves like `modern` |
| `mx.hardware.gpu.vendor` | str or null | `null` | `amd`, `nvidia` or `intel` |
| `mx.hardware.gpu.enable-computing` | bool | `false` | Enable GPU compute stack. Set automatically by the LLM and modeling modules |
| `mx.hardware.gpu.computing` | str or null | `null` | `cuda`, `rocm`, `intel` or `cpu` |
| `mx.hardware.gpu.generation` | str or null | `null` | NVIDIA: `blackwell`, `ada-lovelace`, `ampere`, `pascal`, … — AMD: `rdna4`, `rdna3`, `rdna2`. Intel iGPUs are described by `mx.hardware.cpu.generation` |
| `mx.hardware.framework-fan-ctrl.enable` | bool | `false` | `fw-fanctrl` for Framework laptops |
| `mx.hardware.ssd.lists` | list of str | `[]` | Mountpoints to mount with `noatime,nodiratime,discard,commit=120` |
| `mx.hardware.powersave.enable` | bool | `false` | udev rules switching power profile on AC/battery |
| `mx.hardware.bluetooth.enable` | bool | **`true`** | Setting it to `false` force-disables Bluetooth and drops `gnome-bluetooth` |

### `mx.desktop`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.desktop.environment` | enum `none`, `gnome`, `plasma`, `lxqt` | `none` | `gnome` and `lxqt` configure the DE. `plasma` only selects Plasma-specific behaviour (main screen detection) — **this repo provides no Plasma module**, you must enable it yourself, otherwise a warning is emitted |
| `mx.desktop.gnome.scaling` | int | `1` | GDM scaling factor |
| `mx.desktop.gnome.text-scaling` | float | `1.0` | GDM text scaling factor |
| `mx.desktop.gnome.gsconnect` | bool | `false` | GSConnect, opens the required firewall ports |
| `mx.desktop.gnome.remote-desktop` | bool | `false` | `gnome-remote-desktop`, opens 3389 TCP/UDP |
| `mx.desktop.gnome.numlock` | bool | `true` | NumLock on at login |
| `mx.desktop.gnome.enableTrash` | bool | `true` | Trash support |

### `mx.fonts` / `mx.main-user`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.fonts.enable` | bool | `false` | ~25 extra font packages plus a `mx-use-system-font` helper |
| `mx.main-user.enable` | bool | `false` | Create the primary user |
| `mx.main-user.userName` | str | `"mainuser"` | Username. Gets `wheel` + `networkmanager`, zsh, `initialPassword = "1234"` |
| `mx.main-user.userFullName` | str | `"main user"` | GECOS description |

### `mx.programs`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.programs.games.enable` | bool | `false` | Steam, gamescope, GameMode, MangoHud, Proton-GE + Proton-CachyOS, gaming sysctls, zen kernel |
| `mx.programs.games.users` | list of str | `[]` | Users added to the `gamers` and `gamemode` groups |
| `mx.programs.games.game_lib_dirs` | list of str | `[]` | Shared game library directories, created `0770 root gamers` |
| `mx.programs.games.force-fsr4-for-rdna3` | bool | `false` | Force FSR4 on AMD 7000 series |
| `mx.programs.games.enableHDR` | bool | `false` | HDR support in gamescope |
| `mx.programs.games.lsfg.enable` | bool | `false` | Install `lsfg-vk` (requires the Lossless Scaling app on Steam) |
| `mx.programs.games.lsfg.activate_on_all_games` | bool | `false` | Enable frame generation for every game by default |
| `mx.programs.games.lsfg.steam_library_for_lossless_scaling` | str or null | `null` | Path to the Lossless Scaling DLL |
| `mx.programs.games.gamescopeSession.enable` | bool | `false` | Dedicated gamescope session |
| `mx.programs.games.gamescopeSession.screen.width` | int | `1920` | Session width |
| `mx.programs.games.gamescopeSession.screen.height` | int | `1080` | Session height |
| `mx.programs.games.heroic.enable` | bool | `false` | Heroic Games Launcher |
| `mx.programs.games.lutris.enable` | bool | `false` | Lutris |
| `mx.programs.games.umu.enable` | bool | `false` | UMU launcher |
| `mx.programs.games.latest-unstable-mesa-driver.enable` | bool | `false` | Mesa from nixpkgs-unstable |
| `mx.programs.modeling.enable` | bool | `false` | Blender (CUDA or HIP variant picked from `mx.hardware.gpu.vendor`) and Bambu Studio |
| `mx.programs.obs-studio.enable` | bool | `false` | OBS Studio, virtual camera, vkcapture plugin when games are enabled |
| `mx.programs.team-viewer.enable` | bool | `false` | TeamViewer and its daemon |
| `mx.programs.arduino.enable` | bool | `false` | Arduino IDE, CLI and language server |
| `mx.programs.arduino.users` | list of str | `[]` | Users added to `dialout` and `uucp` |
| `mx.programs.home-manager.enable` | bool | `false` | Enable the Home Manager integration |
| `mx.programs.home-manager.users` | attrs of submodule | `{}` | See [Home Manager](#home-manager) |
| `mx.programs.home-manager.users.<name>.configPath` | path | *required* | Home Manager configuration file |
| `mx.programs.home-manager.users.<name>.homeModule` | str or null | `null` | Name of a module in `self.homeModules` |

### `mx.services`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.services.docker.enable` | bool | `false` | Docker and rootless Docker |
| `mx.services.docker.users` | list of str | `[]` | Users added to the `docker` group |
| `mx.services.lamp.enable` | bool | `false` | Apache + PHP + MariaDB + phpMyAdmin, served from `/var/www/html` |
| `mx.services.postgresql.enable` | bool | `false` | PostgreSQL bound to `127.0.0.1`, plus DBeaver |
| `mx.services.printing.enable` | bool | `false` | CUPS with a broad driver set, avahi, SANE. Adds normal users to `lp` and `scanner` |
| `mx.services.ios-connect.enable` | bool | `false` | iOS device connection tools |
| `mx.services.modulix-daemon.enable` | bool | `false` | `modulix-daemon` systemd D-Bus service and polkit rules |
| `mx.services.modulix-daemon.package` | package | *required* | Daemon package. Has no default — you must set it |
| `mx.services.vm.enable` | bool | `false` | libvirtd, QEMU, SPICE |
| `mx.services.vm.allArchitectures` | bool | `false` | binfmt emulation for aarch64, riscv64 and armv7l |
| `mx.services.vm.users` | list of str | `[]` | Users added to `kvm` and `libvirtd` |
| `mx.services.remote-desktop.enable` | bool | `false` | Sunshine streaming server |
| `mx.services.remote-desktop.app` | list of submodule | `[]` | Applications exposed to Sunshine |

`mx.services.remote-desktop.app.*.<field>`:

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | str | *required* | Application name shown in Moonlight |
| `steam` | bool | `false` | Launch Steam Big Picture automatically |
| `image` | str or null | `null` | Cover image path |
| `command` | list of str | `[]` | Command to run. Use absolute paths — `PATH` is not set |
| `output` | str or null | `null` | Video output to switch to, e.g. `"DP-2"`. Requires `mx.virtual-display.enable` |

### `mx.services.llm`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.services.llm.enable` | bool | `false` | llama.cpp server. Also forces `mx.hardware.gpu.enable-computing = true` |
| `mx.services.llm.host` | str | `"127.0.0.1"` | Listen address |
| `mx.services.llm.port` | port | `8081` | Listen port |
| `mx.services.llm.llamaCppPackage` | package | auto | Selected from `mx.hardware.gpu.computing`: `cuda` → CUDA build, `rocm` → ROCm build, `intel` → Vulkan build, otherwise plain CPU |
| `mx.services.llm.extraFlags` | list of str | `[ "--parallel" "4" "-fa" "on" ]` + `-ngl 99` | Extra llama.cpp flags |
| `mx.services.llm.ramOverflow.enable` | bool | `false` | Automatic GPU/RAM layer overflow via llama.cpp `-fit` |
| `mx.services.llm.ramOverflow.marginMiB` | str | `"1024"` | VRAM margin left free |
| `mx.services.llm.ramOverflow.minCtx` | str | `"4096"` | Minimum context to preserve |
| `mx.services.llm.modelsPreset` | attrs of submodule | `{}` | Model definitions, see below |
| `mx.services.llm.huggingfaceTokenFile` | path | `secrets/shared/huggingface-token.age` | agenix secret holding `HF_TOKEN` |
| `mx.services.llm.enableNewelle` | bool | `true` | Install the Newelle GNOME client |
| `mx.services.llm.open-webui.enable` | bool | `false` | Open WebUI |
| `mx.services.llm.open-webui.package` | package | `pkgs.open-webui` | Open WebUI package |
| `mx.services.llm.open-webui.port` | port | `8080` | Open WebUI port |
| `mx.services.llm.open-webui.extraEnvironment` | attrs of str | `{}` | Extra environment for Open WebUI |

`mx.services.llm.modelsPreset.<name>.<field>` — every field is a string:

| Field | Default | Field | Default |
|---|---|---|---|
| `hf-repo` | *required* | `top-k` | `"40"` |
| `hf-file` | *required* | `min-p` | `"0.01"` |
| `alias` | *required* | `jinja` | `"on"` |
| `ctx-size` | `"8192"` | `load-on-startup` | `"false"` |
| `temp` | `"0.7"` | `stop-timeout` | `"60"` |
| `top-p` | `"0.95"` | | |

### `mx.virtual-display`

Creates fake monitors from generated EDID blobs (`drm.edid_firmware`), with `virtual-display-on` /
`virtual-display-off` and `mx-list-virtual-displays` helpers.

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.virtual-display.enable` | bool | `false` | Virtual displays with Mutter switch/restore scripts |
| `mx.virtual-display.displays` | list of submodule | `[]` | Virtual displays to create |
| `mx.virtual-display.useWayland` | bool | `true` | `wlr-randr` when true, `xrandr` otherwise |
| `mx.virtual-display.default` | str or null | `null` | Default display. Falls back to the first one |
| `mx.virtual-display.sunshine.enable` | bool | `false` | Expose a Sunshine app streaming this virtual display |
| `mx.virtual-display.sunshine.appName` | str | `"Bureau virtuel"` | Sunshine application name |

`mx.virtual-display.displays.*.<field>`:

| Field | Type | Default | Description |
|---|---|---|---|
| `videoOutput` | str | *required* | Connector to attach the EDID to, e.g. `HDMI-A-1` |
| `width` | int | `1920` | Width |
| `height` | int | `1080` | Height |
| `refreshRate` | int | `60` | Refresh rate |
| `enableHdr` | bool | `false` | Add a CEA HDR extension block to the EDID |
| `displayName` | str | `"Virtual Display"` | Monitor name, 13 characters maximum |

## Option reference — Home Manager

These options live in the Home Manager profile under `modules/home-manager/quentin`, so they are only
available if you import it (directly, or via `homeModule = "quentin"`).

### `mx.update` / `mx.auto-update`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.update.flake_path` | str | `"/etc/nixos/flake.nix"` | Flake **directory**. See the note below |
| `mx.update.flake_config` | str | `"default"` | Configuration name inside that flake |
| `mx.auto-update.enable` | bool | `false` | Currently **inert** — the systemd timer that consumes it is commented out in `core/flake-script.nix` |

> The `flake_path` default points at a *file*, but the generated `nix-update` script does
> `cd "$flake_path"`. Always set it to the directory containing your `flake.nix`.

These two options are baked into the `nix-update` and `nix-clean-boot` scripts as
`nixos-rebuild switch --flake <flake_path>#<flake_config>`.

### `mx.services` / `mx.desktop-environment`

| Option | Type | Default | Description |
|---|---|---|---|
| `mx.services.flatpak.enable` | bool | `false` | Flatpak user installation, Flathub remote, Flatseal |
| `mx.desktop-environment.gnome.connection` | bool | `false` | GNOME Connections |
| `mx.desktop-environment.gnome.live-wallpaper` | bool | `false` | Hanabi video wallpaper extension |

### `mx.programs`

| Option | Default | Description |
|---|---|---|
| `mx.programs.audio-enhancer.enable` | `false` | EasyEffects with 7 presets (EQ, bass boost, autogain, mic denoise) |
| `mx.programs.cryptomator.enable` | `false` | Cryptomator |
| `mx.programs.discord.enable` | `false` | Discord as a Flatpak. Forces the Flatpak service on |
| `mx.programs.element.enable` | `false` | Element as a Flatpak. Forces the Flatpak service on |
| `mx.programs.firefox.enable` | `false` | Firefox with enterprise policies (telemetry off, HTTPS-only, tracking protection) and addons |
| `mx.programs.git.enable` | `false` | git with the profile's identity |
| `mx.programs.graphism.enable` | `false` | GIMP 3, Inkscape, Krita, Eyedropper |
| `mx.programs.kdrive.enable` | `false` | kDrive AppImage, desktop entry and user service |
| `mx.programs.linux-base-tools.enable` | `false` | htop, lm_sensors, fastfetch |
| `mx.programs.office.enable` | `false` | TeX Live, TeXstudio, OnlyOffice, LibreOffice, fr/en dictionaries |
| `mx.programs.ssh.enable` | `false` | SSH client configuration |
| `mx.programs.thunderbird.enable` | `false` | Thunderbird |
| `mx.programs.video-downloader.enable` | `false` | Video Downloader |
| `mx.programs.vim.enable` | `false` | Vim |
| `mx.programs.vscode.enable` | `false` | VS Code with pinned extensions, settings and keybindings |
| `mx.programs.winboat.enable` | `false` | Winboat. Asserts Docker is enabled and the user is in `mx.services.docker.users` |
| `mx.programs.zed-editor.enable` | `false` | Zed with LSP configuration, wired to `mx.services.llm` when enabled |
| `mx.programs.dev.enable` | `false` | Base development tools (git, Zeal, Claude Code) |

Language toolchains, each enabled independently under `mx.programs.dev`:

`nix`, `cpp`, `mpi-lib`, `openmp-lib`, `rust`, `python`, `node`, `php`, `sql`, `ci`, `java`,
`gnome-dev` — all `bool`, all default `false`.

Two Home Manager modules have no option of their own and activate from system configuration:
`virt-manager` is installed when the user is listed in `mx.services.vm.users`, and the GNOME profile
applies when `mx.desktop.environment` is `"gnome"`.

## Packages

Available directly from the flake, for all of `x86_64-linux`, `aarch64-linux`, `i686-linux`,
`x86_64-darwin` and `aarch64-darwin`:

```bash
nix run github:qhorgues/NixOS-config#clean-dir
```

| Package | Description |
|---|---|
| `clean-dir` | Recursive development artifact cleaner: `node_modules`, `.venv`, `.docusaurus`, `cargo clean`, CMake `make clean`, build directories, stray executables |
| `nix-clean` | `nix-store --gc` followed by `nix-collect-garbage -d` |
| `nix-latest-update` | `nix store diff-closures` between the last two system generations |
| `lsfg-vk` | Lossless Scaling frame generation Vulkan layer |
| `kiwix` | Kiwix desktop, wrapped to fix GSettings schema lookup |
| `coe33` | Clair Obscur: Expedition 33 save editor (from the `coe33` input) |

Internal derivations in `pkgs/`, pulled in by modules rather than exposed:

| Package | Used by |
|---|---|
| `mx-game` | `mx.programs.games` — stops heavy services, sets performance profile, launches under gamescope, restores on exit |
| `mx-primary-mode` | `mx-game`, prints the primary monitor mode via the Mutter D-Bus API |
| `nix-update` | Home Manager `mx.update` — `git pull` then `nixos-rebuild switch` |
| `nix-clean-boot` | Home Manager `mx.update` — flake update, rebuild, then wipe old generations |
| `proton-cachyos` | `mx.programs.games` — Proton-CachyOS as a Steam compatibility tool |
| `lsfg-vk-ui` | `mx.programs.games.lsfg` — GTK4 configuration UI |
| `hanabi` | `mx.desktop-environment.gnome.live-wallpaper` |
| `phpmyadmin` | `mx.services.lamp` |
| `modulix-icon` | GNOME profile — Modulix-OS icon theme |

## Library helpers

| Helper | Description |
|---|---|
| `lib/edid.nix` | Pure Nix EDID blob generator (CVT timings, checksum, CEA HDR extension block) |
| `lib/display-switch.nix` + `.py` | `activate-virtual-display` / `restore-display`: snapshots the Mutter layout, enables a single output, restores it afterwards. Never written to `monitors.xml` |
| `lib/primary-mode.py` | Prints the primary monitor mode as `WxH@R`, correct under fractional scaling |
| `lib/game-settings-switcher.nix` | Exposed as `lib.mkGameConfigSwitcher`. Swaps per-GPU game config files inside a Proton prefix |
| `lib/igpu-launch.nix` | Exposed as `lib.igpu-launch`. Sets `MESA_VK_DEVICE_SELECT`/`DRI_PRIME` and fixes up `MANGOHUD_CONFIG` |

## Secrets (agenix)

`secrets.nix` is the rules file: it maps each encrypted file to the public keys allowed to decrypt
it. The `core/agenix.nix` module installs the `agenix` CLI, enables OpenSSH (firewall closed by
default) and sets `age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]` — so decryption relies on
the **host** SSH key.

To add a secret:

1. Add your user and host public keys to `secrets.nix`
   (`ssh-keyscan` or `cat /etc/ssh/ssh_host_ed25519_key.pub`).
2. Add a rule mapping the secret path to those keys:

   ```nix
   "secrets/my-host/my-secret.age".publicKeys = [ quentin-my-host host-my-host ];
   ```

3. Create or edit the secret:

   ```bash
   nix run github:ryantm/agenix -- -e secrets/my-host/my-secret.age
   ```

4. Declare it in the module that needs it and read the decrypted path at runtime:

   ```nix
   age.secrets.my-secret.file = ../../../secrets/my-host/my-secret.age;
   # → /run/agenix/my-secret
   ```

After changing the key list, re-key with `agenix -r`.

The flake also passes `secretsPath` (this repository's `secrets/` directory) as a module argument.

## Encrypted root with TPM 2.0

Add to the LUKS device section:

```diff
  boot.initrd.luks.devices."<luks device id>" = {
    device = "/dev/disk/by-uuid/<PARTITION UUID>";
+   preLVM = true;
+   allowDiscards = true;
  };
```

Then, after rebuilding and rebooting:

```bash
# TPM with auto unlock
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<LUKS_PARTITION>
# OR
# TPM unlock with PIN
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 --tpm2-with-pin=yes /dev/<LUKS_PARTITION>
```

## CI

A nightly GitHub Actions workflow runs `nix flake update`, opens a pull request, and merges it after
a delay if `flake.lock` is the only changed file. See
[`.github/workflows/README.md`](.github/workflows/README.md) for details.

`gitlab-ci.yml` is the GitLab equivalent. It is inactive as committed — copy it to `.gitlab-ci.yml`
at the repository root for GitLab to pick it up.

## License

See [LICENSE](LICENSE).
