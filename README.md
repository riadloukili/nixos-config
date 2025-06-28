# NixOS Config

Universal, flake-based NixOS configurations (stable 25.05 "Warbler") for multiple machines and cloud providers.

**Production-ready features**: Auto-updates, smart garbage collection, Docker integration, advanced dotfiles, security hardening, and comprehensive automation.

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

## Features

### 🔄 Auto-Update System
- **Daily automatic updates** from GitHub repository
- **Configurable timing** (default: 02:00 with randomized delay)
- **Optional automatic reboot** capability
- **Enhanced logging** to systemd journal

### 🗑️ Smart Garbage Collection
- **Intelligent cleanup** preserving minimum generations (default: 5)
- **Time-based deletion** with configurable age thresholds (default: 7 days)
- **Store optimization** for disk space management
- **Bootloader integration** with configuration limits

### 🐳 Docker Integration
- **Rootless Docker** by default for enhanced security
- **Docker Compose** support with optional package inclusion
- **Configurable security modes**

### 🏠 Advanced Home Manager
- **Comprehensive dotfiles management** with custom themes
- **Zsh with Oh My Zsh** and Powerlevel10k theme
- **Cloud provider integration** with provider-specific icons
- **Modern CLI tools**: ripgrep, fd, bat, htop
- **Advanced Tmux configuration** with TPM plugin manager

### 🔐 Security Hardening
- **SSH key-only authentication** (password auth disabled)
- **Firewall integration** with explicit port management
- **Passwordless sudo** for wheel group members
- **Root login disabled** by default

### 📦 Package Management
- **Custom package option** (`mySystem.packages`)
- **Profile system**: base and server configurations
- **Declarative package lists** per host

### 🌐 Networking & Services
- **DNS management** with Cloudflare and Quad9 defaults
- **Multiple bootloader support** (GRUB and systemd-boot)
- **OpenSSH hardening** with configurable ports

## Repository layout

```
nixos-config/
├── flake.nix                      ← top-level flake definition
├── README.md
├── modules/                       ← reusable module fragments
│   ├── packages.nix               ← custom package-list option
│   ├── services/                  ← modular service configurations
│   │   ├── auto-update.nix        ← automatic system updates
│   │   ├── garbage-collection.nix ← smart cleanup & optimization
│   │   ├── docker.nix             ← rootless Docker integration
│   │   ├── networking.nix         ← DNS and network configuration
│   │   ├── openssh.nix            ← SSH service module
│   │   ├── firewall.nix           ← firewall service module
│   │   └── boot.nix               ← boot loader module
│   └── users/                     ← per-user SSH & account info
│       ├── default.nix            ← imports all `<user>.nix`
│       └── riad.nix               ← includes home-manager config
├── profiles/                      ← high-level package profiles
│   ├── base.nix                   ← essential packages & services
│   └── server.nix                 ← production server configuration
├── dotfiles/                      ← custom dotfiles and themes
│   └── riad/                      ← user-specific configurations
│       ├── p10k.zsh               ← Powerlevel10k theme with cloud icons
│       └── tmux.conf              ← advanced Tmux configuration
└── hosts/                         ← per-machine configs, grouped by provider
    ├── hetzner/
    │   └── eu-lite-nix-1/
    │       ├── hardware-configuration.nix
    │       └── configuration.nix
    ├── aws/
    ├── digitalocean/
    └── home/
```

## Adding a new machine

> **Provider-specific guides**: See [Hetzner installation guide](hosts/hetzner/README.md) for detailed Hetzner setup instructions.

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
3. **Write `configuration.nix`** in that folder. For a basic setup:

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

4. **For production servers**, use the server profile:

   ```nix
   imports = [
     # ... other imports ...
     ../../../profiles/server.nix  # Includes auto-updates, Docker, etc.
   ];
   ```

5. **Machines are automatically discovered!**
   
   The flake automatically discovers all machines in the `hosts/` directory and creates configurations named `<provider>-<machine-id>`. No need to manually edit `flake.nix`!

6. **Install or rebuild**

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
* **Control sudo per-host**: in each host's `configuration.nix`:

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
3. **Shared profiles**: 
   - `profiles/base.nix` — essential packages for all systems
   - `profiles/server.nix` — production server packages with Docker and auto-updates

## Service Configuration

### Auto-Update Service
Enable automatic daily updates in your `configuration.nix`:

```nix
mySystem.auto-update = {
  enable = true;
  time = "02:00";  # Optional: custom time
  autoReboot = false;  # Optional: enable automatic reboots
};
```

### Garbage Collection
Configure smart cleanup (included in base profile):

```nix
mySystem.garbage-collection = {
  enable = true;
  time = "03:00";
  preserveGenerations = 5;  # Keep minimum 5 generations
  olderThan = "7d";  # Delete older than 7 days
};
```

### Docker Service
Enable rootless Docker:

```nix
mySystem.docker = {
  enable = true;
  rootless = true;  # Default: true
  enableCompose = true;  # Optional: include docker-compose
};
```

## Useful commands

* `nix flake show` — list all available machine configurations
* `nix flake check` — validate flake syntax and configurations
* `nix flake update` — update your Nixpkgs channel
* `sudo nixos-install --flake .#<provider-machine-id>` — fresh install
* `sudo nixos-rebuild switch --flake .#<provider-machine-id>` — apply changes live
* `sudo nixos-rebuild test --flake .#<provider-machine-id>` — test without switching
* `sudo nixos-rebuild build --flake .#<provider-machine-id>` — build without applying
* `rebuild` — convenient alias that auto-detects provider and hostname (uses GitHub repo)
* `rebuild --refresh` — force refetch latest changes from GitHub repository
