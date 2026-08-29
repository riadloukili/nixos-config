# Cloud VM (e.g. Hetzner, legacy BIOS): GPT with BIOS boot partition + ESP so
# GRUB works either way, ext4 root, swap partition. Pair with boot.grub.
# Host sets my.disk.device (and optionally my.disk.swapSize).
{
  flake.modules.nixos."disko/cloud-bios" =
    { config, diskParts, ... }:
    {
      imports = [ ./_disk.nix ];

      disko.devices.disk.main = {
        type = "disk";
        inherit (config.my.disk) device;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              priority = 1;
              size = "1M";
              type = "EF02";
            };
            ESP = diskParts.esp "512M" // {
              priority = 2;
            };
            swap = {
              size = config.my.disk.swapSize;
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
