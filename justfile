# Day-to-day tasks. `just` lists them; run inside `nix develop` / direnv.

set shell := ["bash", "-euo", "pipefail", "-c"]

flake := justfile_directory()
host := `hostname`

# List recipes
default:
    @just --list --unsorted

# Build a host without activating (default: this machine)
build target=host:
    nh os build {{ flake }} -H {{ target }}

# Build and activate on this machine
switch:
    nh os switch {{ flake }} -H {{ host }}

# Build and activate on next boot only
boot:
    nh os boot {{ flake }} -H {{ host }}

# Build here, activate on a remote host over SSH
push target:
    nh os switch {{ flake }} -H {{ target }} --target-host riad@{{ target }}

# Build an installer image: server | desktop | <host>
iso target:
    nix build {{ flake }}#iso-{{ target }} -L --out-link result-iso-{{ target }}
    @ls -1 result-iso-{{ target }}/iso/

# Boot a host configuration in a throwaway VM
vm target:
    nix build {{ flake }}#nixosConfigurations.{{ target }}.config.system.build.vm -L
    ./result/bin/run-{{ target }}-vm

# Formatting, lints, hooks and every host
check:
    nix flake check {{ flake }} -L

# Format the tree
fmt:
    nix fmt {{ flake }}

# Update all flake inputs (or one: `just update nixpkgs`)
update input="":
    nix flake update {{ input }} --flake {{ flake }}

# Closure diff between the running system and a fresh build
diff target=host:
    nh os build {{ flake }} -H {{ target }} --out-link result-diff-{{ target }}
    nvd diff /run/current-system result-diff-{{ target }}

# Enrol a host's SSH host key as the sops recipient `host-<name>` and re-encrypt secrets
sops-add-host name address:
    #!/usr/bin/env bash
    set -euo pipefail
    key=$(ssh-keyscan -t ed25519 "{{ address }}" 2>/dev/null | ssh-to-age)
    [ -n "$key" ] || { echo "no ed25519 host key from {{ address }}" >&2; exit 1; }
    echo "{{ name }}: $key"
    if grep -qE '^[[:space:]]*-[[:space:]]*&host-{{ name }} ' .sops.yaml; then
      sed -i "s|&host-{{ name }} age1.*|\&host-{{ name }} $key|" .sops.yaml
    else
      sed -i "/^keys:/a\\  - &host-{{ name }} $key" .sops.yaml
    fi
    shopt -s nullglob
    for f in secrets/*.yaml; do sops updatekeys --yes "$f"; done
    echo "Now list '*host-{{ name }}' under the creation_rules that should include it, and re-run updatekeys."

# Edit (or create) an encrypted secrets file
secrets-edit file="common":
    sops secrets/{{ file }}.yaml

# Remove build results
clean:
    rm -f result*
