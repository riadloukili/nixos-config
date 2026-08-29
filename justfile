# Task runner. `just` lists everything; run inside `nix develop` / direnv.

set shell := ["bash", "-euo", "pipefail", "-c"]

flake := justfile_directory()
host := `hostname`

# List recipes
default:
    @just --list --unsorted

# Build a host closure without activating (default: this machine)
build target=host:
    nh os build {{ flake }} -H {{ target }}

# Build and activate on this machine
switch:
    nh os switch {{ flake }} -H {{ host }}

# Build and activate on next boot only
boot:
    nh os boot {{ flake }} -H {{ host }}

# Build locally, then activate on a remote host over SSH (ad-hoc, no rollback)
push target:
    nh os switch {{ flake }} -H {{ target }} --target-host riad@{{ target }}

# Deploy with deploy-rs (magic rollback); `just deploy` deploys every node
deploy target="":
    deploy --skip-checks {{ flake }}{{ if target != "" { "#" + target } else { "" } }}

# Show what a deploy would change on a host
deploy-dry target:
    deploy --skip-checks --dry-activate {{ flake }}#{{ target }}

# Build an installer image: server | desktop | <host>
iso target:
    nix build {{ flake }}#iso-{{ target }} -L --out-link result-iso-{{ target }}
    @ls -1 result-iso-{{ target }}/iso/

# Boot a host configuration in a throwaway VM
vm target:
    nix build {{ flake }}#nixosConfigurations.{{ target }}.config.system.build.vm -L
    ./result/bin/run-{{ target }}-vm

# Evaluate everything (formatting, lints, hooks, hosts, deploy schema)
check:
    nix flake check {{ flake }} -L

# Format the tree
fmt:
    nix fmt {{ flake }}

# Update all flake inputs (or one: `just update nixpkgs`)
update input="":
    nix flake update {{ input }} --flake {{ flake }}

# Show the closure diff between the running system and a fresh build
diff target=host:
    nh os build {{ flake }} -H {{ target }} --out-link /tmp/nixos-config-{{ target }}
    nvd diff /run/current-system /tmp/nixos-config-{{ target }}

# Enrol a host's SSH host key as a sops recipient and re-encrypt secrets
sops-add-host name address:
    #!/usr/bin/env bash
    set -euo pipefail
    key=$(ssh-keyscan -t ed25519 "{{ address }}" 2>/dev/null | ssh-to-age)
    echo "{{ name }}: $key"
    if grep -q "&{{ name }}" .sops.yaml; then
      sed -i "s|&{{ name }} age1.*|\&{{ name }} $key|" .sops.yaml
    else
      sed -i "/^keys:/a\\  - &{{ name }} $key" .sops.yaml
    fi
    for f in secrets/*.yaml; do
      [ -f "$f" ] && sops updatekeys --yes "$f" || true
    done
    echo "Add '{{ name }}' to the creation_rules in .sops.yaml if it is not covered yet."

# Edit (or create) an encrypted secrets file
secrets-edit file="common":
    sops secrets/{{ file }}.yaml

# Print the age recipient for a hashed password prompt
mkpasswd:
    mkpasswd -m yescrypt

# Remove build results
clean:
    rm -f result result-*
