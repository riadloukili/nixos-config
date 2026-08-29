# Lenovo ThinkPad common bits.
{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    lenovo-thinkpad
    common-pc-laptop
    common-pc-laptop-ssd
  ];
  hardware.trackpoint.enable = true;
}
