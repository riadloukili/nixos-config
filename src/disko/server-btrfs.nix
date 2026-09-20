# Headless server: GPT, 1G ESP, unencrypted btrfs subvolumes (unattended reboots), swapfile.
# Host sets my.disk.device (and optionally my.disk.swapSize).
{
  flake.modules.nixos."disko/server-btrfs" =
    { config, diskParts, ... }:
    {
      imports = [ ./_disk.nix ];

      disko.devices.disk.main = {
        type = "disk";
        inherit (config.my.disk) device;
        content = {
          type = "gpt";
          partitions = {
            ESP = diskParts.esp "1G";
            root = {
              size = "100%";
              content = diskParts.btrfs;
            };
          };
        };
      };
      fileSystems."/var/log".neededForBoot = true;
    };
}
