# Laptop: GPT, 1G ESP, LUKS2 (passphrase at boot) -> btrfs subvolumes, swapfile.
# Host sets my.disk.device (and optionally my.disk.swapSize).
{
  flake.modules.nixos."disko/laptop-luks-btrfs" =
    { config, lib, ... }:
    let
      cfg = config.my.disk;
      opts = [
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
          default = "16G";
        };
      };

      config = {
        disko.devices.disk.main = {
          type = "disk";
          inherit (cfg) device;
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
                        swap.swapfile.size = cfg.swapSize;
                      };
                    };
                  };
                };
              };
            };
          };
        };
        fileSystems."/var/log".neededForBoot = lib.mkDefault true;
      };
    };
}
