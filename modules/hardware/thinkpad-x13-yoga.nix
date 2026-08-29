# Lenovo ThinkPad X13 Yoga (Gen 4, Intel). nixos-hardware has no Gen 4 entry;
# the generic x13-yoga module covers thinkpad + laptop + ssd + intel cpu +
# rotation sensor + psmouse + wacom + thunderbolt (bolt).
{ inputs, lib, ... }:
{
  flake.modules.nixos."hardware/thinkpad-x13-yoga" = {
    imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga ];
    # Same throttling quirk as the Gen 3 entry (U-series stuck at low clocks).
    services.throttled.enable = lib.mkDefault true;
  };
}
