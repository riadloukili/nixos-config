# Laptop: GPT, 1G ESP, LUKS2 (passphrase at boot) -> btrfs subvolumes, swapfile.
{
  device,
  swapSize ? "16G",
}:
{ lib, ... }:
let
  opts = [
    "compress=zstd"
    "noatime"
  ];
in
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
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
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
  };
  fileSystems."/var/log".neededForBoot = lib.mkDefault true;
}
