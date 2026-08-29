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

- `flake.nix` = inputs; `import-tree` loads every `.nix` under `flake/ modules/ profiles/ hosts/ installer/ disko/` plus `users/*/default.nix` as flake-parts modules (files starting with `_` are skipped; under `users/<name>/` only `default.nix` is loaded — the rest is the user's own, imported by it). `flake/` builds outputs; the other directories only *register aspects*: `flake.modules.nixos.<name>` / `flake.modules.homeManager.<name>`.
- `flake/mods.nix` exposes the registry as the `mods` module argument (`{ mods, ... }:` at the top of a file), **nested by path** and with each aspect wrapped in a `key` so importing an aspect from several profiles deduplicates. Use `mods`, never `config.flake.modules` inside an aspect (the inner NixOS `config` shadows it). `flake.modules` itself is two-level, so nested names are registered with `/`: `flake.modules.nixos."hardware/thinkpad"`.
- Naming = path: `modules/desktop/hyprland.nix` → `"desktop/hyprland"` → `mods.nixos.desktop.hyprland`; `modules/docker.nix` → `mods.nixos.docker`; `modules/dotfiles.nix` → `mods.homeManager.dotfiles`; `profiles/x.nix` → `mods.nixos.profiles.x`; `users/x/default.nix` → `mods.nixos.users.x`; `installer/x.nix` → `mods.nixos.installer.x`; `disko/x.nix` → `mods.nixos.disko.x`; `hosts/<p>/<n>/{default,hardware,disko}.nix` → `mods.nixos.hosts.<n>.{default,hardware,disk}`.
- `flake/hosts.nix` discovers `hosts/<provider>/<name>/` and builds `nixosConfigurations.<name>` from the three host aspects (+ home-manager, disko, sops modules; hostname and `$CLOUD_PROVIDER` from the directory names). `flake/iso.nix` reuses `hosts.<name>.default` (without hardware/disk) for `iso-<name>`. Adding a host = adding a directory.
- Profiles: `profiles.base` → `profiles.server` | `profiles.desktop` → `profiles.laptop`; they own the software a machine class needs (system packages, e.g. `desktop/tools.nix`). Users own their stuff: `users/<name>/default.nix` (system user + `home-manager.users.<name> = ./home.nix`) and `home.nix` (home-manager: shell, editor, personal tools, theme). Don't create shared home-manager aspects for personal preferences.
- `my.<x>` options only when parametrised (`my.firewall`, `my.docker`, `my.autoUpdate`, `my.gc`, `my.secrets`, `my.repo`, `my.installer`, HM `my.dotfiles`). `modules/secrets.nix` declares all sops secrets and is inert until `secrets/common.yaml` exists.
- `modules/dotfiles.nix` (HM aspect, in `profiles.base`): links every top-level dir of the dotfiles checkout (`my.dotfiles.path`, default `~/personal/dotfiles`) into `~/.config`. No defaults are shipped in this repo — missing checkout/entry means the program's own defaults. Never require the checkout.
- `modules/shell.nix`: zsh is the login shell system-wide; its config lives in each user's `home.nix` (`programs.zsh`).
- `disko/<layout>.nix` registers `disko/<layout>`, an aspect that declares `my.disk.{device,swapSize}` and names its disk `main`; a host's `disko.nix` imports one and sets the device.
- Servers pull `main` daily (`modules/auto-update.nix`): pushing to `main` deploys. Work on branches; CI must be green.

## Conventions

- Small files, a comment at the top saying what the file is for; `nix fmt` before committing (enforced by hooks).
- `stateVersion` is set per host and never bumped. Host names: Horizon Forbidden West GAIA subfunctions.
