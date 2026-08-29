# Reusable disk layouts (modules/hardware/disko/*) are functions
# `{ device, ... } -> nixosModule` registered here; hosts call one from
# their disko.nix.
{ lib, ... }:
{
  options.flake.diskoLayouts = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.functionTo lib.types.deferredModule);
    default = { };
    description = "Named disko layouts, parameterised by device.";
  };
}
