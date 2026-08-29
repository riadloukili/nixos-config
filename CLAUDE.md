# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

A flake-parts + import-tree ("dendritic") NixOS configuration for a small personal fleet. No application code, no tests; "building" means evaluating closures. README.md is accurate — read it first.

## Commands

```bash
nix develop                 # dev shell (also via direnv); installs pre-commit hooks
just                        # list tasks
just check                  # nix flake check: treefmt, deadnix/statix, pre-commit, inventory, deploy schema, all hosts
just fmt                    # nix fmt (treefmt: nixfmt, deadnix, statix, yamlfmt, mdformat, taplo, just, shfmt, typos)
nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath   # fast single-host eval
nix build .#nixosConfigurations.<host>.config.system.build.toplevel          # full single-host build
nix build .#iso-<host>|iso-server|iso-desktop                                # installer images
```

**Flakes only see git-tracked files: `git add` new files before evaluating.**

## Architecture

- `flake.nix` holds inputs only; `outputs = inputs: flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./modules)`. Never add hosts or imports to it.
- Every `modules/**/*.nix` is a flake-parts module. Paths containing `/_` are ignored (`_template` dirs/files).
- Aspects: `flake.modules.nixos.<dir>-<name>` and `flake.modules.homeManager.home-<name>`. Reference other aspects via the *flake-level* `config.flake.modules...`. Inner NixOS/HM modules shadow `config`; bind the flake config in a `let aspects = config.flake.modules;` at file top (see `modules/desktop/compositors.nix`).
- Roles (`modules/roles`) are pure import lists: `base` → `server` → `homelab` | `cloud`; `laptop`. **An aspect must be imported by exactly one role/host path** — flake-parts does not deduplicate anonymous module imports, so importing the same aspect twice raises "option declared multiple times".
- Hosts: `modules/hosts/<name>/{default,hardware,disko}.nix` register `flake.hosts.<name>` (inventory: channel, provider, stateVersion, deploy, iso, modules, hardwareModules). `modules/flake/hosts.nix` builds `nixosConfigurations`; `deploy.nix` derives deploy-rs nodes; `installers.nix` derives `iso-<host>` (software modules only + `installer-base` + `installer-target`).
- Options namespace: `my.*` (`my.firewall`, `my.docker`, `my.autoUpdate`, `my.gc`, `my.secrets`, `my.desktop.compositors`, `my.repo`, `my.home.modules`, `my.installer`, HM: `my.dotfiles`). Only parametrised modules have options; everything else is on/off by import.
- home-manager aspects reach users through `my.home.modules` (set by roles/aspects); `core/users/riad.nix` imports that list.
- Channels: `flake.channels.{unstable,stable}` (nixpkgs + matching home-manager). Hosts default to unstable. `pkgs.stable`/`pkgs.unstable` overlay exists for one-off pins.
- Disko layouts are functions in `flake.diskoLayouts.<name> { device; swapSize; }`; host `disko.nix` calls one. Every layout names its disk `main`.
- Wrappers (`modules/wrappers`) use nix-wrapper-modules; they are exported as `packages.<system>.<name>` automatically and installed for the user by `home-wrappers`; the zsh wrapper is the login shell (`core-zsh-wrapper`). Never overlay the git wrapper as `pkgs.git`.
- Secrets: `secrets-sops` only enables sops once `secrets/common.yaml` exists (`my.secrets.enable`), so fresh hosts build before enrolment. Add a secret = add a file under `modules/secrets/` guarded by `my.secrets.enable`.
- Firewall is touched by `services/firewall.nix`, `services/docker.nix` (trusted interfaces, rp filter, UDP 53), `core/ssh.nix` (openFirewall) and `services/tailscale.nix`.
- Pushing to `main` deploys: server-role hosts run `system.autoUpgrade` from `github:riadloukili/nixos-config#<hostname>` daily. Work on branches; CI must be green.

## Conventions

- One concern per file, small files, comment at the top saying what the file is for.
- Formatting/lints are enforced by `nix flake check`; run `just fmt` before committing.
- `stateVersion` is per host in the inventory and never changes.
- Host names come from Horizon Forbidden West's GAIA subfunctions.
