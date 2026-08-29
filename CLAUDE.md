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

## Structure

- `flake.nix` = inputs; `flake/*.nix` are flake-parts modules auto-imported by import-tree (hosts discovery, ISOs, wrappers, devshell, treefmt, git-hooks, checks). Everything outside `flake/` is a plain NixOS / home-manager module imported by path — no aspect registry, no inventory DSL.
- `hosts/<provider>/<name>/`: `default.nix` (imports profiles + users, sets options), `hardware.nix`, `disko.nix`. `flake/hosts.nix` adds the latter two automatically (so `flake/iso.nix` can reuse `default.nix` for the live image) and sets `networking.hostName` / `$CLOUD_PROVIDER` from the directory names. Adding a host = adding a directory.
- `profiles/`: `base` → `server` | `desktop` → `laptop`. They import `modules/*` and add `home/*` via `home-manager.sharedModules`. Importing a module from several places is fine (path-deduplicated).
- `users/<name>.nix` = system user + `home-manager.users.<name> = ./<name>/home.nix`.
- `modules/`: one thing per file; `my.<x>` options only when parametrised (`my.firewall`, `my.docker`, `my.autoUpdate`, `my.gc`, `my.secrets`, `my.repo`, `my.installer`). `modules/secrets.nix` declares all sops secrets and is inert until `secrets/common.yaml` exists.
- `home/dotfiles.nix`: layered configs. A module that installs a program declares `my.dotfiles.entries.<name>.default = ./defaults/<name>`; activation links `~/.config/<name>` to `<my.dotfiles.path>/<name>` if the checkout has it, else to the default. Never require the checkout.
- `wrappers/<name>.nix` = nix-wrapper-modules module, auto-registered by `flake/wrappers.nix` as `flake.wrappers.<name>` and `packages.<system>.<name>`; `wrappers/dotfiles.nix` is a shared constant, not a wrapper. The zsh wrapper is the login shell (`modules/shell.nix`); never overlay the git wrapper as `pkgs.git`.
- `disko/<layout>.nix` = `{ device, swapSize } -> nixosModule`; every layout names its disk `main`.
- Servers pull `main` daily (`modules/auto-update.nix`): pushing to `main` deploys. Work on branches; CI must be green.

## Conventions

- Small files, a comment at the top saying what the file is for; `nix fmt` before committing (enforced by hooks).
- `stateVersion` is set per host and never bumped. Host names: Horizon Forbidden West GAIA subfunctions.
