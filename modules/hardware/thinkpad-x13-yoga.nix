# Lenovo ThinkPad X13 Yoga Gen 4 (i5-1345U, Raptor Lake U, Iris Xe).
# nixos-hardware has no Gen 4 entry; the generic x13-yoga module covers
# thinkpad + laptop + ssd + intel cpu + rotation sensor + psmouse + wacom +
# thunderbolt (bolt).
{ inputs, lib, ... }:
{
  flake.modules.nixos."hardware/thinkpad-x13-yoga" = {
    imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga ];
    # Same throttling quirk as the Gen 3 entry (i5-1235U): U-series CPUs get
    # stuck around 1.3 GHz without it. Check with `journalctl -u throttled`.
    services.throttled.enable = lib.mkDefault true;
  };
}
