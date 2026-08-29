# Cloud VM (e.g. Hetzner, legacy BIOS): GPT with BIOS boot partition + ESP so
# GRUB works either way, ext4 root, swap partition. Pair with boot.grub.
# Host sets my.disk.device (and optionally my.disk.swapSize).
{
  flake.modules.nixos."disko/cloud-bios" =
    { config, lib, ... }:
    let
      cfg = config.my.disk;
    in
    {
      options.my.disk = {
        device = lib.mkOption {
          type = lib.types.str;
          example = "/dev/nvme0n1";
          description = "Disk this layout is applied to.";
        };
        swapSize = lib.mkOption {
          type = lib.types.str;
          default = "2G";
        };
      };

      config = {
        disko.devices.disk.main = {
          type = "disk";
          inherit (cfg) device;
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
                size = cfg.swapSize;
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
    };
}
