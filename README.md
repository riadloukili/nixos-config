# NixOS Config

Universal, flake-based NixOS configurations (stable 25.05 “Warbler”) for multiple machines and cloud providers.

## Prerequisites

* Nix 2.8+ with flakes enabled
* Git
* SSH access (for deployment)
* A Hetzner/AWS/DO/etc. VM or local machine with the NixOS ISO

## Getting started

1. **Clone this repo**

   ```bash
   git clone https://github.com/riadloukili/nixos-config.git
   cd nixos-config
   ```
2. **Change the channel** (if needed)
   Edit `flake.nix` to point at a different `nixos-<version>` channel.
3. **Install or rebuild a host**

   ```bash
   sudo nixos-install --flake .#<machine-id>
   # …or, after first install…
   sudo nixos-rebuild switch --flake .#<machine-id>
   ```

## Repository layout

```
nixos-config/
├── flake.nix                 ← top-level flake definition
├── README.md
├── modules/                  ← reusable module fragments
│   ├── networking.nix
│   ├── packages.nix          ← custom package-list option
│   └── users/                ← per-user SSH & account info
│       ├── default.nix       ← imports all `<user>.nix`
│       ├── riad.nix
│       └── alice.nix
├── profiles/                 ← high-level package profiles
│   └── base.nix
└── hosts/                    ← per-machine configs, grouped by provider
    ├── hetzner/
    │   └── eu-lite-nix-1/
    │       ├── hardware-configuration.nix
    │       └── configuration.nix
    ├── aws/
    └── digitalocean/
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
   { config, pkgs, lib, … }:
   {
     imports = [ ./hardware-configuration.nix ];
     networking.hostName = "<machine-id>";
     time.timeZone = "America/Toronto";
     i18n.defaultLocale = "en_US.UTF-8";

     # Per-host sudo:
     users.users.<username>.extraGroups = [ "wheel" ];

     services.openssh.enable = true;
     networking.firewall.allowedTCPPorts = [ 22 ];

     # Custom packages:
     mySystem.packages = [ pkgs.git pkgs.vim ];

     system.stateVersion = "25.05";
   }
   ```
4. **Expose it in `flake.nix`**
   Under `nixosConfigurations`, add:

   ```nix
   "my-new-vm" = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [
       ./modules/packages.nix
       ./modules/users
       ./hosts/<provider>/<machine-id>/configuration.nix
     ];
   };
   ```
5. **Install or rebuild**

   ```bash
   sudo nixos-install --flake .#my-new-vm
   # or later:
   sudo nixos-rebuild switch --flake .#my-new-vm
   ```

## Managing users

* **Define a user**: add `modules/users/<username>.nix`:

  ```nix
  { config, lib, … }:
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

* `nix flake update` — update your Nixpkgs channel
* `sudo nixos-install --flake .#<machine-id>` — fresh install
* `sudo nixos-rebuild switch --flake .#<machine-id>` — apply changes live
* `nixos-rebuild test --flake .#<machine-id>` — test without switching
