# Invariants over the inventory, evaluated by `nix flake check`.
{ config, lib, ... }:
let
  hosts = config.flake.hosts;
  deployHostnames = lib.mapAttrsToList (_: h: h.deploy.hostname) (
    lib.filterAttrs (_: h: h.deploy != null) hosts
  );
  duplicates = lib.subtractLists (lib.unique deployHostnames) deployHostnames;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks.inventory =
        pkgs.runCommand "inventory-check"
          {
            hosts = lib.concatStringsSep " " (lib.attrNames hosts);
            dups = lib.concatStringsSep " " duplicates;
          }
          ''
            if [ -n "$dups" ]; then
              echo "duplicate deploy hostnames: $dups" >&2
              exit 1
            fi
            echo "hosts: $hosts" > "$out"
          '';
    };
}
