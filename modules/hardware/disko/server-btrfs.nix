# Headless server layout: GPT, 1G ESP, unencrypted btrfs subvolumes (so the
# machine can reboot unattended), swapfile subvolume.
{ lib, ... }:
{
  flake.diskoLayouts.serverBtrfs =
    {
      device,
      swapSize ? "8G",
    }:
    {
      disko.devices.disk.main = {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes =
                  let
                    opts = [
                      "compress=zstd"
                      "noatime"
                    ];
                  in
                  {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = opts;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = opts;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = opts;
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = opts;
                    };
                    "@swap" = {
                      mountpoint = "/.swap";
                      swap.swapfile.size = swapSize;
                    };
                  };
              };
            };
          };
        };
      };
      fileSystems."/var/log".neededForBoot = lib.mkDefault true;
    };
}
