# apollo disk: single NVMe, unencrypted btrfs (unattended reboots).
{ config, ... }:
{
  flake.modules.nixos.hosts-apollo-disk = config.flake.diskoLayouts.serverBtrfs {
    device = "/dev/nvme0n1";
    swapSize = "8G";
  };
}
