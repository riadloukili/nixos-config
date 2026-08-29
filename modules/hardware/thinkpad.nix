# Lenovo ThinkPad common bits (TrackPoint, acpi, throttling fixes).
{ inputs, ... }:
{
  flake.modules.nixos.hardware-thinkpad = {
    imports = with inputs.nixos-hardware.nixosModules; [
      lenovo-thinkpad
      common-pc-laptop
      common-pc-laptop-ssd
    ];
    hardware.trackpoint.enable = true;
  };
}
