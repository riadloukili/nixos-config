# `nix flake check` also builds every host (and, with them, the ISOs' inputs).
{ config, lib, ... }:
{
  perSystem.checks = lib.mapAttrs' (
    name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel
  ) config.flake.nixosConfigurations;
}
