# CLAUDE.md

Guidance for Claude Code in this repository. README.md is accurate — read it first.

## Commands

```bash
nix develop                        # dev shell (direnv works); installs pre-commit hooks
just check                         # nix flake check: treefmt, statix/deadnix, pre-commit, builds every host
just fmt                           # nix fmt (treefmt)
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath   # fast single-host eval
nix build .#iso-<host>|iso-server|iso-desktop
```

**Flakes only see git-tracked files: `git add` new files before evaluating.**

## Structure (dendritic)

- `flake.nix` = inputs; `import-tree` loads every `.nix` under `flake/ modules/ profiles/ users/ home/ hosts/ installer/ disko/ wrappers/` as a flake-parts module (files starting with `_` are skipped: helpers). `flake/` builds outputs; the other directories only *register aspects*: `flake.modules.nixos.<name>` / `flake.modules.homeManager.<name>`.
- `flake/mods.nix` exposes the registry as the `mods` module argument (`{ mods, ... }:` at the top of a file), **nested by path** and with each aspect wrapped in a `key` so importing an aspect from several profiles deduplicates. Use `mods`, never `config.flake.modules` inside an aspect (the inner NixOS `config` shadows it). `flake.modules` itself is two-level, so nested names are registered with `/`: `flake.modules.nixos."hardware/thinkpad"`.
- Naming = path: `modules/desktop/hyprland.nix` → `"desktop/hyprland"` → `mods.nixos.desktop.hyprland`; `modules/docker.nix` → `mods.nixos.docker`; `home/cli.nix` → `mods.homeManager.cli`; `profiles/x.nix` → `mods.nixos.profiles.x`; `users/x.nix` → `mods.nixos.users.x` (+ `mods.homeManager.users.x` from `users/x/home.nix`); `installer/x.nix` → `mods.nixos.installer.x`; `disko/x.nix` → `mods.nixos.disko.x`; `hosts/<p>/<n>/{default,hardware,disko}.nix` → `mods.nixos.hosts.<n>.{default,hardware,disk}`.
- `flake/hosts.nix` discovers `hosts/<provider>/<name>/` and builds `nixosConfigurations.<name>` from the three host aspects (+ home-manager, disko, sops modules; hostname and `$CLOUD_PROVIDER` from the directory names). `flake/iso.nix` reuses `hosts.<name>.default` (without hardware/disk) for `iso-<name>`. Adding a host = adding a directory.
- Profiles: `profiles.base` → `profiles.server` | `profiles.desktop` → `profiles.laptop`; they import aspects and add home-manager aspects via `home-manager.sharedModules`. One file can hold both halves of a feature (`modules/desktop/hyprland.nix`).
- `my.<x>` options only when parametrised (`my.firewall`, `my.docker`, `my.autoUpdate`, `my.gc`, `my.secrets`, `my.repo`, `my.installer`, HM `my.dotfiles`). `modules/secrets.nix` declares all sops secrets and is inert until `secrets/common.yaml` exists.
- `home/dotfiles.nix`: layered configs — an aspect that installs a program sets `my.dotfiles.entries.<name>.default = ./defaults/<name>`; activation links `~/.config/<name>` to `<my.dotfiles.path>/<name>` if the checkout has it, else to the default. Never require the checkout.
- `wrappers/<name>.nix` registers `flake.wrappers.<name>` (a nix-wrapper-modules module); the wrappers flake module exports each as `packages.<system>.<name>`. `wrappers/_dotfiles.nix` is a shared constant. The zsh wrapper is the login shell (`modules/shell.nix`); never overlay the git wrapper as `pkgs.git`.
- `disko/<layout>.nix` registers `disko/<layout>`, an aspect that declares `my.disk.{device,swapSize}` and names its disk `main`; a host's `disko.nix` imports one and sets the device.
- Servers pull `main` daily (`modules/auto-update.nix`): pushing to `main` deploys. Work on branches; CI must be green.

## Conventions

- Small files, a comment at the top saying what the file is for; `nix fmt` before committing (enforced by hooks).
- `stateVersion` is set per host and never bumped. Host names: Horizon Forbidden West GAIA subfunctions.
