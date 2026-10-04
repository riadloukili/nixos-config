# eleuthia disk: single NVMe, LUKS + btrfs, with the tail of the disk kept for
# a Windows install. Only this host dual-boots, so the generic
# disko/laptop-luks-btrfs layout stays as it is and the extra partitions are
# added here.
{ mods, lib, ... }:
{
  flake.modules.nixos."hosts/eleuthia/disk" = {
    imports = [ mods.nixos.disko.laptop-luks-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
      swapSize = "16G";
    };

    # Partitions are created in priority order, which is also their order on
    # the disk: ESP (1), LUKS root, then Windows' own two. The root partition
    # therefore needs an explicit size instead of the layout's 100%.
    # No content on the Windows partitions: disko creates them but leaves the
    # formatting to the Windows installer.
    disko.devices.disk.main.content.partitions = {
      luks = {
        priority = 2;
        size = lib.mkForce "325G";
      };
      msr = {
        priority = 3;
        size = "16M";
        type = "0C01"; # Microsoft reserved
      };
      windows = {
        priority = 4;
        size = "100%";
        type = "0700"; # Microsoft basic data
      };
    };
  };
}
