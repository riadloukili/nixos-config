# nixos-config

My NixOS machines: a homelab server, a laptop, and room for cloud VMs.

```text
flake.nix        inputs only; import-tree loads every .nix file below as a flake-parts module
flake/           builds the outputs: hosts discovery, ISOs, wrappers, devshell, formatter/lints, the `mods` registry
hosts/<provider>/<name>/   one machine: default.nix (profiles + users + options), hardware.nix, disko.nix
profiles/        presets a host composes: base → server | desktop → laptop
users/           system users; users/<name>/home.nix is their home-manager config
modules/         one small NixOS aspect per thing (docker, firewall, gc, secrets, desktop/*, hardware/*, boot/*)
home/            small home-manager aspects (cli, dev, neovim, wayland, desktop, dotfiles) + defaults/
wrappers/        programs bundled with their config (nvim, zsh, tmux, git, btop) + defaults/
disko/           disk layouts, functions of { device, swapSize }
installer/       live-ISO base + the offline install-<host> script
secrets/         sops-encrypted YAML; .sops.yaml lists recipients
```

Hosts are named after GAIA's subfunctions (Horizon Forbidden West): `apollo`, `eleuthia`; free: `aether artemis demeter hades hephaestus minerva poseidon`.

## How it fits together (dendritic)

Every `.nix` file is a flake-parts module that *registers* an aspect under a name:

```nix
# modules/docker.nix
{ flake.modules.nixos.docker = { config, lib, pkgs, ... }: { ... }; }
# home/cli.nix
{ flake.modules.homeManager.cli = { pkgs, ... }: { ... }; }
```

`flake/mods.nix` hands the registry back to every file as the `mods` argument, so composition is by name — and each aspect carries a `key`, so importing the same one from several places is deduplicated:

```nix
# hosts/home/eleuthia/default.nix
{ mods, ... }: {
  flake.modules.nixos.host-eleuthia = {
    imports = with mods.nixos; [ profile-laptop user-riad boot-systemd-boot hardware-intel hardware-thinkpad ];
    system.stateVersion = "26.11";
  };
}
```

- Names: `modules/desktop/hyprland.nix` → `mods.nixos.desktop-hyprland`; `home/cli.nix` → `mods.homeManager.cli`; `profiles/server.nix` → `profile-server`; `users/riad.nix` → `user-riad`; a host registers `host-<name>`, `host-<name>-hardware`, `host-<name>-disk`.
- `flake/hosts.nix` finds every `hosts/<provider>/<name>/`, sets `networking.hostName = <name>` and `$CLOUD_PROVIDER = <provider>`, and builds `nixosConfigurations.<name>` from the three host aspects.
- A file may carry both halves of a feature (see `modules/desktop/hyprland.nix`: NixOS part + home-manager part).
- Profiles import aspects and add home-manager aspects through `home-manager.sharedModules`.
- Options live under `my.*` only where an aspect needs parameters (`my.firewall`, `my.docker`, `my.autoUpdate`, `my.gc`, `my.secrets`, `my.repo`, `my.dotfiles`). Everything else is on/off by import.
- `stateVersion` is set per host and never changes. Flakes only see git-tracked files: `git add` new files before evaluating.

## Daily use

```sh
nix develop          # or direnv; installs the pre-commit hooks
just                 # list tasks
just switch          # rebuild this machine (nh)
just build apollo    # build another host without activating
just push apollo     # build here, activate over SSH
just iso eleuthia    # installer image → result-iso-eleuthia/iso/nixos-eleuthia.iso
just check           # nix flake check: formatting, lints, hooks, every host
just fmt
```

Servers (`profiles/server.nix`) pull `main` daily (`my.autoUpdate`), so **pushing to `main` deploys**. CI runs `nix flake check` and builds the ISOs on pull requests.

## Installing a machine

1. Create `hosts/<provider>/<name>/` with `default.nix`, `hardware.nix` (from `nixos-generate-config --no-filesystems --show-hardware-config`) and `disko.nix` (a call to one of `disko/*.nix`).

1. Either build the image — `just iso <name>`, `dd` it to USB, boot, run `install-<name>` (offline; runs disko + nixos-install from the closure on the image) — or use the stock installer:

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko/latest -- \
     --mode destroy,format,mount --flake 'github:riadloukili/nixos-config#<name>'
   sudo nixos-install --flake 'github:riadloukili/nixos-config#<name>' --no-root-passwd --no-channel-copy
   sudo nixos-enter --root /mnt -c 'passwd riad'   # no password until secrets are enrolled
   ```

1. Reboot, then from a machine with the admin age key: `just sops-add-host <name> <ip>`, add `*<name>` to the relevant `creation_rules` in `.sops.yaml`, `just secrets-edit common` (needs `riad-password` from `just mkpasswd`, and `tailscale-auth-key` for servers), `just push <name>`.

Live images log in as `riad` / `nixos`; SSH keys work everywhere.

## Secrets

sops-nix with age. Recipients: the admin key (`~/.config/sops/age/keys.txt`) plus each host's SSH host key via `ssh-to-age`. `secrets/common.yaml` is readable by every host, `secrets/<host>.yaml` by one host, `secrets/user.yaml` by the user's home-manager. `modules/secrets.nix` only activates once `secrets/common.yaml` exists, so a fresh host builds before enrolment; add secrets there.

## Dotfiles: defaults + optional overrides

Every program this config installs has a default config in the repo (`home/defaults/<name>`, `wrappers/defaults/`). A dotfiles checkout at `~/personal/dotfiles` (`my.dotfiles.path`) is optional and overrides per entry: at activation, `~/.config/<name>` is linked to `<checkout>/<name>` if it exists, otherwise to the default. Overrides are hot-editable (no rebuild); changing a default is a rebuild. The `nvim`, `tmux` and `zsh` wrappers resolve the same way at start-up, so `nix run github:riadloukili/nixos-config#nvim` works on any machine with or without the checkout.

Entries: `hypr/` `waybar/` `rofi/` `swaync/` `wlogout/` `nvim/` `tmux/tmux.conf` `zsh/p10k.zsh` `zsh/zshrc.local`. See [riadloukili/dotfiles](https://github.com/riadloukili/dotfiles).

## Editor

`nixd` is in the dev shell; point it at `(builtins.getFlake (toString ./.)).nixosConfigurations.eleuthia.options` for option completion.
