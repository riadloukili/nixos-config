# Cloud VM layout (e.g. Hetzner Cloud, legacy BIOS boot): GPT with a 1M BIOS
# boot partition + ESP so GRUB works in both BIOS and EFI, ext4 root, swap.
# Pair with core-boot-grub.
{
  flake.diskoLayouts.cloudBios =
    {
      device,
      swapSize ? "2G",
    }:
    {
      disko.devices.disk.main = {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              priority = 1;
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = swapSize;
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
}
