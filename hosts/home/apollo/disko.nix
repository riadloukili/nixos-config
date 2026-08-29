# apollo disk: single NVMe, unencrypted btrfs (unattended reboots).
{ mods, ... }:
{
  flake.modules.nixos."hosts/apollo/disk" = {
    imports = [ mods.nixos.disko.server-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
    };
  };
}
