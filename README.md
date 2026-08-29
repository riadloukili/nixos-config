# nixos-config

My NixOS machines: a homelab server, a laptop, and room for cloud VMs.

```text
flake.nix        inputs only; import-tree loads every .nix file below as a flake-parts module
flake/           builds the outputs: hosts discovery, ISOs, devshell, formatter/lints, the `mods` registry
hosts/<provider>/<name>/   one machine: default.nix (profiles + users + options), hardware.nix, disko.nix
profiles/        presets a host composes: base → server | desktop → laptop
users/<name>/    one user: default.nix (system user, registers users.<name>) + whatever they want
                 (home.nix = their home-manager config, scripts, ...). Only default.nix is auto-loaded.
modules/         one small NixOS aspect per thing (docker, firewall, gc, secrets, dotfiles, desktop/*, hardware/*, boot/*)
disko/           disk-layout aspects; a host picks one and sets my.disk.device
installer/       live-ISO base + the offline install-<host> script
secrets/         sops-encrypted YAML; .sops.yaml lists recipients
```

Hosts are named after GAIA's subfunctions (Horizon Forbidden West): `apollo`, `eleuthia`; free: `aether artemis demeter hades hephaestus minerva poseidon`.

## How it fits together (dendritic)

Every `.nix` file is a flake-parts module that *registers* an aspect under a name:

```nix
# modules/docker.nix
{ flake.modules.nixos.docker = { config, lib, pkgs, ... }: { ... }; }
# modules/hardware/thinkpad.nix
{ flake.modules.nixos."hardware/thinkpad" = { ... }; }
# modules/dotfiles.nix
{ flake.modules.homeManager.dotfiles = { config, lib, pkgs, ... }: { ... }; }
```

`flake/mods.nix` hands the registry back to every file as the `mods` argument, nested by path (`"hardware/thinkpad"` → `mods.nixos.hardware.thinkpad`), so composition is by name — and each aspect carries a `key`, so importing the same one from several places is deduplicated:

```nix
# hosts/home/eleuthia/default.nix
{ mods, ... }: {
  flake.modules.nixos."hosts/eleuthia/default" = {
    imports = with mods.nixos; [ profiles.laptop users.riad boot.systemd-boot hardware.intel hardware.thinkpad-x13-yoga-x13-yoga ];
    system.stateVersion = "26.11";
  };
}
```

- Names mirror paths: `modules/desktop/hyprland.nix` → `mods.nixos.desktop.hyprland`; `modules/docker.nix` → `mods.nixos.docker`; `profiles/server.nix` → `mods.nixos.profiles.server`; `users/riad/default.nix` → `mods.nixos.users.riad`; `disko/server-btrfs.nix` → `mods.nixos.disko.server-btrfs`; `modules/dotfiles.nix` → `mods.homeManager.dotfiles`; a host registers `hosts/<name>/{default,hardware,disk}`. Files starting with `_` are helpers, not modules.
- `flake/hosts.nix` finds every `hosts/<provider>/<name>/`, sets `networking.hostName = <name>` and `$CLOUD_PROVIDER = <provider>`, and builds `nixosConfigurations.<name>` from the three host aspects.
- A file may carry both halves of a feature (see `modules/desktop/hyprland.nix`: NixOS part + home-manager part).
- Profiles own the software a class of machine needs (`desktop.tools` installs waybar/rofi/kitty/… system-wide). A user's folder owns everything about that user: `users/<name>/default.nix` is the system user and points `home-manager.users.<name>` at `./home.nix`, which is theirs to organise.
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

1. Create `hosts/<provider>/<name>/` with `default.nix`, `hardware.nix` (from `nixos-generate-config --no-filesystems --show-hardware-config`) and `disko.nix` (imports one `mods.nixos.disko.*` aspect and sets `my.disk.device`).

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

## Dotfiles

Program configs are not in this repo. `modules/dotfiles.nix` links every top-level directory of the checkout at `~/personal/dotfiles` ([riadloukili/dotfiles](https://github.com/riadloukili/dotfiles)) into `~/.config/<name>` at activation — live symlinks, so editing needs no rebuild. No checkout, or no `hypr/` in it → Hyprland (or waybar, nvim, tmux, …) runs with its own built-in defaults. Set `my.dotfiles.path` per user to use a different repo.

## Editor

`nixd` is in the dev shell; point it at `(builtins.getFlake (toString ./.)).nixosConfigurations.eleuthia.options` for option completion.
