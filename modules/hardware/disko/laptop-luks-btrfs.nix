# Laptop layout: GPT, 1G ESP, LUKS2 (passphrase at boot) -> btrfs subvolumes
# with zstd compression and a swapfile subvolume.
{ lib, ... }:
{
  flake.diskoLayouts.laptopLuksBtrfs =
    {
      device,
      swapSize ? "16G",
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                # Interactive passphrase at install time and at boot.
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
      };
      fileSystems."/var/log".neededForBoot = lib.mkDefault true;
    };
}
