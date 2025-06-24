# NixOS Config

Universal, flake-based NixOS configurations (stable 25.05 “Warbler”) for multiple machines and cloud providers.

## Prerequisites

* Nix 2.8+ with flakes enabled
* Git
* SSH access (for deployment)
* A Hetzner/AWS/DO/etc. VM or local machine with the NixOS ISO

## Getting started

You can either clone the repository locally or use it directly from GitHub:

### Option 1: Clone locally (for development)

1. **Clone this repo**

   ```bash
   git clone https://github.com/riadloukili/nixos-config.git
   cd nixos-config
   ```
2. **Change the channel** (if needed)
   Edit `flake.nix` to point at a different `nixos-<version>` channel.
3. **Install or rebuild a host**

   ```bash
   sudo nixos-install --flake .#<provider-machine-id>
   # ...or, after first install...
   sudo nixos-rebuild switch --flake .#<provider-machine-id>
   ```

### Option 2: Use directly from GitHub (for deployment)

**Install or rebuild a host directly**

```bash
sudo nixos-install --flake github:riadloukili/nixos-config#<provider-machine-id>
# ...or, after first install...
sudo nixos-rebuild switch --flake github:riadloukili/nixos-config#<provider-machine-id>
```

Machine IDs are automatically generated as `<provider>-<machine>` (e.g., `hetzner-eu-lite-nix-1`).

## Repository layout

```
nixos-config/
├── flake.nix                 ← top-level flake definition
├── README.md
├── modules/                  ← reusable module fragments
│   ├── packages.nix          ← custom package-list option
│   ├── services/             ← modular service configurations
│   │   ├── openssh.nix       ← SSH service module
│   │   ├── firewall.nix      ← firewall service module
│   │   └── boot.nix          ← boot loader module
│   └── users/                ← per-user SSH & account info
│       ├── default.nix       ← imports all `<user>.nix`
│       └── riad.nix          ← includes home-manager config
├── profiles/                 ← high-level package profiles
│   └── base.nix
└── hosts/                    ← per-machine configs, grouped by provider
    ├── hetzner/
    │   └── eu-lite-nix-1/
    │       ├── hardware-configuration.nix
    │       └── configuration.nix
    ├── aws/
    ├── digitalocean/
    └── home/
```

## Adding a new machine

1. **Create the directory**

   ```bash
   mkdir -p hosts/<provider>/<machine-id>
   ```
2. **Generate hardware config**
   Boot the NixOS ISO on your target VM, partition & label your disks, mount under `/mnt`, then:

   ```bash
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix \
      hosts/<provider>/<machine-id>/
   ```
3. **Write `configuration.nix`** in that folder. At minimum:

   ```nix
   { config, pkgs, lib, inputs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ../../../modules/packages.nix
       ../../../modules/users
       ../../../modules/services/openssh.nix
       ../../../modules/services/firewall.nix
       ../../../modules/services/boot.nix
       ../../../profiles/base.nix
       inputs.home-manager.nixosModules.home-manager
     ];

     networking.hostName = builtins.baseNameOf ./.;
     time.timeZone = "America/Toronto";
     i18n.defaultLocale = "en_US.UTF-8";

     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     environment.variables.CLOUD_PROVIDER = builtins.baseNameOf (builtins.dirOf ./.); 

     users.users.<username>.extraGroups = [ "wheel" ];
     users.defaultUserShell = pkgs.zsh;
     programs.zsh.enable = true;
     security.sudo.wheelNeedsPassword = false;

     mySystem.openssh = {
       enable = true;
       passwordAuthentication = false;
       ports = [ 22 ];
     };

     mySystem.firewall = {
       enable = true;
       allowedTCPPorts = [ 22 ];
     };

     mySystem.boot = {
       loader = "grub";
       device = "/dev/sda";
     };

     home-manager = {
       useGlobalPkgs = true;
       useUserPackages = true;
     };

     mySystem.packages = [];
     system.stateVersion = "25.05";
   }
   ```
4. **Machines are automatically discovered!**
   
   The flake automatically discovers all machines in the `hosts/` directory and creates configurations named `<provider>-<machine-id>`. No need to manually edit `flake.nix`!

5. **Install or rebuild**

   ```bash
   sudo nixos-install --flake .#<provider>-<machine-id>
   # or later:
   sudo nixos-rebuild switch --flake .#<provider>-<machine-id>
   # or use the rebuild alias once logged in:
   rebuild
   ```

## Managing users

* **Define a user**: add `modules/users/<username>.nix`:

  ```nix
  { config, lib, ... }:
  {
    users.users.<username> = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ "<their-public-key>" ];
    };
  }
  ```
* **Control sudo per-host**: in each host’s `configuration.nix`:

  ```nix
  users.users.<username>.extraGroups = [ "wheel" ];
  security.sudo.wheelNeedsPassword = false;
  ```

## Managing packages

1. **Declare the option** in `modules/packages.nix` as `mySystem.packages`.
2. **Per-host packages**: in `configuration.nix`:

   ```nix
   mySystem.packages = [
     pkgs.curl
     pkgs.htop
   ];
   ```
3. **Shared profiles**: create `profiles/base.nix` and import it via `flake.nix`’s modules list.

## Useful commands

* `nix flake show` — list all available machine configurations
* `nix flake check` — validate flake syntax and configurations
* `nix flake update` — update your Nixpkgs channel
* `sudo nixos-install --flake .#<provider-machine-id>` — fresh install
* `sudo nixos-rebuild switch --flake .#<provider-machine-id>` — apply changes live
* `sudo nixos-rebuild test --flake .#<provider-machine-id>` — test without switching
* `sudo nixos-rebuild build --flake .#<provider-machine-id>` — build without applying
* `rebuild` — convenient alias that auto-detects provider and hostname (uses GitHub repo)
