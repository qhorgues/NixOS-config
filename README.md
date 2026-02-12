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

### 1. Install NixOS ISO

Download the NixOS ISO from the [official website](https://nixos.org/download) and create a bootable USB drive using the `dd` command or software like [Ventoy](https://www.ventoy.net/en/index.html) or [BalenaEtcher](https://www.balena.io/etcher/).

After installation reboot imediatly in bios setup

### 2. Pass secure boot in edit mode

### 3. Create secure boot key
  Boot in your newest installation of NixOS

  ```bash
  sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl -- create-keys
  sudo nix --extra-experimental-features "nix-command flakes" run nixpkgs#sbctl -- enroll-keys --microsoft --firmware-builtin
  ```

### 4. Clone the repository:
  ```bash
  cd ~
  git clone https://github.com/qhorgues/NixOS-config config
  cd config
  ```

### 5. Setup the configuration:
  ```bash
  mkdir ./hosts/<computer_name>
  cp /etc/nixos/configuration.nix ~/config/hosts/<computer_name>/configuration.nix
  cp /etc/nixos/hardware-configuration.nix ~/config/hosts/<computer_name>/hardware-configuration.nix
  ```
  Erase all content in `~/config/hosts/<computer_name>/configuration.nix` content and replace by this template

  ```nix
{ self, config, pkgs, inputs, pkgs-unstable, ... }:
{
  imports = [
    # List kardware modules (eg: inputs.nixos-hardware.nixosModules.<module_name>)
  
    ../../modules/nixos/core # Core module
    ../../modules/nixos/fonts # Extra font module
    ../../modules/nixos/gnome # Import gnome module
    ../../modules/nixos/home-manager # Import home-manager module

    # Import other system module (eg: ../../module/nixos/<module_name>.nix) 
  ];

  networking.hostName = "<host name>";

  winter = {
    hardware = {
      framework-fan-ctrl.enable = true; # true ONLY if you use a framework laptop, otherise you can juste remove this line
      gpu = {
        vendor = "amdgpu"; # null, nvidia, amdgpu or intel 
        acceleration = "rocm"; # null, rocm ou cuda
        frame-generation.enable = true; # If you have modern GPU with frame generation support
        generation = "rdna3"; 
        # Generation of the GPU 
        # for AMD: gcn-5-gen, rdna, rdna2, rdna3, rdna4, ...
        # for NVIDIA: pascal, turing, ada-lovelace, blackwell, ...
      };
    };
    main-user = {
      enable = true; # Enable main user with full admin access
      userName = "<user_name>"; # Username of the main user
      userFullName = "<Full Name>"; # Full name of the main user
    };
    gnome = {
      # This is apply in gdm only  
      scaling = 2; # Scaling factor for the display
      text-scaling = 0.7; # Scaling factor for text
    };
    # Optional if you use VM list users trusted to use the VM
    vm = {
      users = [ "<user_name>" ];
    };
  };
  
  # Add settings for home manager
  home-manager = {
    extraSpecialArgs = {
        inherit self inputs pkgs pkgs-unstable;
        system-version=config.system.nixos.release;
    };
    users = {
        "<user_name>" = import ./<user_name>.nix; # Replace by your user name
    };
  };
}
  ```

  All hardware module available can be found in the [nixos-hardware](https://github.com/NixOS/nixos-hardware) repository and for system module, in folder `modules/nixos`

### 6. Setup home manager

  Create file `~/config/hosts/<computer_name>/<user_name>.nix`
  And copy this template

  ```nix
  { system-version, ... }:
  {
    imports = [
      ../../modules/home-manager
      # Import other modules here like ../../modules/home-manager/firefox
    ];
  
    winter = {
      update = {
          flake_path = "<full path to your config>";
          flake_config = "<config_name>";
      };
      auto-update.enable = true; # Actually broken
    };
  
    home.username = "<user_name>";
    home.homeDirectory = "<full path to your home directory>";
    nixpkgs.config.allowUnfree = true;
    home.keyboard = {
      layout = "fr";
      variant = "fr";
    };
 
    home.stateVersion = system-version;
  }
  ```

### 7. Add your host in flake
In flake.nix add in section nixosConfigurations this
  ```nix
  "<config_name>" = let
    system = "<architecture>"; # eg x86_64-linux
  in nixpkgs.lib.nixosSystem {
    system = system;
    specialArgs = { inherit self inputs;
        pkgs-unstable = import nixpkgs-unstable {
            system = system;
            config = nixpkgsConfig;
        };
    };
    modules = [
        ./hosts/<computer_name>/configuration.nix
        inputs.home-manager.nixosModules.default
    ];
  };
  ```

### 8. Apply the configuration:
  ```bash
  sudo nixos-rebuild switch --flake ~/config#<config_name>
   ```

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
```bash
# TPM with auto unlock
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/<LUKS_PARTITION>
# OR
# TPM unlock with PIN
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 --tpm2-with-pin=yes /dev/<LUKS_PARTITION>
```
