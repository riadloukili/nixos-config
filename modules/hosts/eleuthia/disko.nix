# eleuthia disk: single NVMe, LUKS + btrfs.
{ config, ... }:
{
  flake.modules.nixos.hosts-eleuthia-disk = config.flake.diskoLayouts.laptopLuksBtrfs {
    device = "/dev/nvme0n1";
    swapSize = "16G";
  };
}
