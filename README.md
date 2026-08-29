# nixos-config

Flake-based NixOS configuration for my machines: headless homelab servers, cloud VMs and a laptop with Hyprland + Mango.

- **NixOS**: `nixos-unstable` by default, `nixos-26.05` available per host (`channel = "stable"`).
- **Structure**: [flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree), dendritic style — every file under `modules/` is auto-imported and registers named *aspects*; a host is an import list.
- **Disks**: [disko](https://github.com/nix-community/disko) layouts, reusable per machine class.
- **Deploy**: [nh](https://github.com/nix-community/nh) locally, [deploy-rs](https://github.com/serokell/deploy-rs) push, `system.autoUpgrade` pull from `main`.
- **Secrets**: [sops-nix](https://github.com/Mic92/sops-nix) for the system, [secretspec](https://secretspec.dev) for the dev shell.
- **Programs**: [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules) for nvim/zsh/tmux/git/btop (runnable anywhere with `nix run`); all configs live in the separate [dotfiles](https://github.com/riadloukili/dotfiles) checkout, hot-editable and shared with non-Nix machines.
- **Installers**: live ISOs per role or per host, with an offline `install-<host>` command.

Hosts are named after GAIA's subfunctions (Horizon Forbidden West): `apollo` (homelab), `eleuthia` (laptop); free: `aether artemis demeter hades hephaestus minerva poseidon`.

## Layout

```text
flake.nix              inputs only — never edited to add hosts or features
justfile               all day-to-day tasks (`just`)
modules/
  flake/               flake-level plumbing: hosts inventory, channels, deploy, installers, devshell, checks
  core/                aspects every host gets (nix, ssh, users, gc, nh, boot loaders, ...)
  roles/               pure import lists: base → server → homelab | cloud ; laptop
  services/            parametrised modules with `my.<x>` options (docker, firewall, auto-update, tailscale)
  hardware/            hardware aspects + disko/ layouts
  desktop/             NixOS halves of the desktop (greetd, compositors, pipewire, portals, fonts, keyboard)
  home/                home-manager aspects (cli, neovim, dotfiles, wayland stack, ...)
  wrappers/            nix-wrapper-modules programs → also flake packages
  secrets/             sops-nix wiring and individual secrets
  installer/           live-ISO base and the per-host install script
  hosts/<name>/        default.nix (inventory + software), hardware.nix, disko.nix
secrets/               sops-encrypted YAML (common.yaml, <host>.yaml, user.yaml, devshell.yaml)
```

### How composition works

Each file contributes aspects:

```nix
{ flake.modules.nixos.services-tailscale = { ... }; }
{ flake.modules.homeManager.home-cli = { ... }; }
```

Roles are import lists of aspects; hosts import a role plus hardware aspects and register themselves in the inventory:

```nix
flake.hosts.apollo = {
  stateVersion = "26.11";
  deploy.hostname = "apollo";
  modules = [ config.flake.modules.nixos.hosts-apollo ];               # software
  hardwareModules = [ ...hosts-apollo-hardware ...hosts-apollo-disk ]; # excluded from the live ISO
};
```

`modules/flake/hosts.nix` turns the inventory into `nixosConfigurations`, `deploy.nix` into deploy-rs nodes, `installers.nix` into `iso-<host>` images.

Rules of thumb:

- One concern per file. Add a feature = add a file.
- Aspects are on/off by import. `mkEnableOption` only for modules that need parameters (`my.firewall`, `my.docker`, ...).
- An aspect is imported by exactly one role (flake-parts does not deduplicate module imports).
- home-manager aspects are added through `my.home.modules`; every user in `core/users` picks them up.
- Never bump `stateVersion`.

## Everyday use

```sh
nix develop            # or direnv; installs pre-commit hooks
just                   # list tasks
just switch            # rebuild this machine (nh)
just build apollo      # build a host without activating
just deploy apollo     # deploy-rs with magic rollback
just push apollo       # ad-hoc: nh os switch --target-host
just iso eleuthia      # build result-iso-eleuthia/iso/nixos-eleuthia.iso
just check             # nix flake check: formatting, lints, hooks, hosts, deploy schema
just fmt
```

Servers also pull `main` daily (`my.autoUpdate`), so **pushing to `main` deploys**. CI builds every host and ISO on pull requests; keep the branch green before merging.

## Installing a machine

1. Add `modules/hosts/<name>/` (copy `_template`), pick a disko layout and set the device.
1. `just iso <name>`, write the image to USB (`dd if=result-iso-<name>/iso/*.iso of=/dev/sdX bs=4M status=progress`).
1. Boot it. You get the host's real desktop/server config live (user `riad`, password `nixos`, SSH keys work).
1. `install-<name> --dry-run`, then `install-<name>`. It runs the disko script (asks for confirmation, prompts for the LUKS passphrase on encrypted layouts) and `nixos-install` from the closure on the image — no network needed.
1. Reboot, then from this repo: `just sops-add-host <name> <ip>` and add the host to the relevant `creation_rules` in `.sops.yaml`; `just deploy <name>`.
1. On desktops: `git clone https://github.com/riadloukili/dotfiles ~/personal/dotfiles` (hot-editable configs), `fprintd-enroll`.

Generic images: `just iso server` / `just iso desktop`.

### Installing from the stock NixOS installer (no custom ISO)

Boot any NixOS installer, open a terminal, check the target disk matches the host's `disko.nix` (`lsblk`), then:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake 'github:riadloukili/nixos-config#<name>'     # LUKS layouts prompt for the passphrase
sudo nixos-install --flake 'github:riadloukili/nixos-config#<name>' --no-root-passwd --no-channel-copy
sudo nixos-enter --root /mnt -c 'passwd riad'   # until secrets are enrolled the user has no password
reboot
```

Use `github:riadloukili/nixos-config/<branch>#<name>` for an unmerged branch. `nixos-install --flake` builds into `/mnt`'s store, so the live system's RAM is not a limit (unlike `disko-install`, which builds in the live store first).

## Secrets

- **System secrets** (sops-nix): `secrets/common.yaml` is readable by every host; `secrets/<host>.yaml` by one host. Recipients are the admin age key (`~/.config/sops/age/keys.txt`) plus each host's SSH host key converted with `ssh-to-age`. `just secrets-edit common` creates or edits a file. Declare a secret in a small aspect under `modules/secrets/` (see `user-password.nix`).
- **User secrets** (home-manager): `secrets/user.yaml`, decrypted with the admin age key.
- **Dev-shell secrets** (secretspec): `secretspec.toml` declares them, `secrets/devshell.yaml` holds them (`sops://` provider). `secretspec check` / `secretspec run -- <cmd>`. secretspec is *not* a NixOS secret backend.

Expected keys in `common.yaml`: `riad-password` (`mkpasswd -m yescrypt`), `tailscale-auth-key`.

## Dotfiles

Hot-edited configs (`hypr`, `mango`, `waybar`, `rofi`, `swaync`, `wlogout`, `wallust`, `nvim`) live in the separate dotfiles repo and are symlinked from `~/personal/dotfiles` (`my.dotfiles`, `mkOutOfStoreSymlink`) — edit and reload, no rebuild. Set `my.dotfiles.mutable = false` with a store `source` to freeze them.

CLI programs are wrapper modules (`modules/wrappers`): `nix run github:riadloukili/nixos-config#nvim` (or `#tmux`, `#zsh`, `#git`, `#btop`) works on any machine with Nix. The *config* is not duplicated: `nvim` loads `<dotfiles>/nvim`, `tmux` sources `<dotfiles>/tmux/tmux.conf`, `zsh` sources `<dotfiles>/zsh/p10k.zsh` and `zsh/zshrc.local` — the same files a non-Nix machine uses directly. Nix only adds the binary, plugins and tools (LSPs, formatters). All lookups are guarded, so the wrappers still start when no checkout is present.

`flake.dotfiles.runtime` (`$HOME/personal/dotfiles`) is where wrappers look at start-up. Once the dotfiles repo is on GitHub, add it as `inputs.dotfiles = { url = "github:riadloukili/dotfiles"; flake = false; }` and set `flake.dotfiles.store = inputs.dotfiles` in `modules/wrappers/dotfiles.nix` to have `nix run` bundle the config as well (then `nix flake update dotfiles` refreshes it).

## Editor

nixd is in the dev shell. Suggested settings (e.g. for nvim-lspconfig):

```lua
settings = { nixd = {
  nixpkgs = { expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }" },
  options = {
    nixos = { expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.eleuthia.options" },
    home_manager = { expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.eleuthia.options.home-manager.users.type.getSubOptions []" },
  },
} }
```
