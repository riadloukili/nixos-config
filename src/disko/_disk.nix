# Shared by the disko layouts (not an aspect: the `_` keeps import-tree away).
# Declares `my.disk` and provides the building blocks the layouts assemble.
{ config, lib, ... }:
let
  cfg = config.my.disk;
  btrfsOpts = [
    "compress=zstd"
    "noatime"
  ];
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
      default = "8G";
    };
  };

  config = {
    assertions = [
      {
        assertion = lib.hasPrefix "/dev/" cfg.device;
        message = "my.disk.device must be a /dev/ path, got ${cfg.device}";
      }
    ];

    # Building blocks, read by the layouts as `config.my.disk.parts.*`.
    _module.args.diskParts = {
      esp = size: {
        priority = 1;
        inherit size;
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };
      # btrfs with the usual subvolumes and a swapfile subvolume.
      btrfs = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "@" = {
            mountpoint = "/";
            mountOptions = btrfsOpts;
          };
          "@home" = {
            mountpoint = "/home";
            mountOptions = btrfsOpts;
          };
          "@nix" = {
            mountpoint = "/nix";
            mountOptions = btrfsOpts;
          };
          "@log" = {
            mountpoint = "/var/log";
            mountOptions = btrfsOpts;
          };
          "@swap" = {
            mountpoint = "/.swap";
            swap.swapfile.size = cfg.swapSize;
          };
        };
      };
    };
  };
}
