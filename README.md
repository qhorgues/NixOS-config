# My NixOS Config

Modular NixOS configuration managed with Flakes. It offers machine and user environment management, with a clear structure and reusable modules.

## Features

- Configuration via Nix Flakes: reproducible and modular
- User configuration with Home Manager
- Support for multiple hosts: laptop, desktop, etc.
- Clear separation between system and user modules
- Integrated custom packages
- Configuration of KDrive, Pipewire, Gnome, Steam, Firefox, VM, etc...

## Repository structure

```
.
├── flake.nix             → Main flake declaration
├── flake.lock            → Lock dependencies
├── hosts/                → Machine-specific configurations
├── modules/
│   ├── nixos/            → System modules for NixOS
│   └── home-manager/     → Modules for user configuration
└── pkgs/                 → Custom packages
```

## Installation


1. Clone the repository:
   ```bash
   git clone https://github.com/qhorgues/NixOS-config
   cd NixOS-config
   ```

2. Apply the configuration:
   `sudo nixos-rebuild switch --flake .#nixos-desktop`
   *(Replace \`nixos-desktop\` with your target host)*

## Crypt with TPM 2.0

add in crypt device section

```diff
  boot.initrd.luks.devices."<luks device id>" = {
    device = "/dev/disk/by-uuid/<PARTITION UUID>";
+   preLVM = true;
+   allowDiscards = true;
  };
```

and execute after rebuild and reboot
```
# TPM with auto unlock
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<LUKS_PARTITION>
# OR
# TPM unlock with PIN
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 --tpm2-with-pin=yes /dev/<LUKS_PARTITION>
```
