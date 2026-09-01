# Laptop: GPT, 1G ESP, LUKS2 (passphrase at boot) -> btrfs subvolumes, swapfile.
# Host sets my.disk.device (and optionally my.disk.swapSize).
{
  flake.modules.nixos."disko/laptop-luks-btrfs" =
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                content = diskParts.btrfs;
              };
            };
          };
        };
      };
      fileSystems."/var/log".neededForBoot = true;
    };
}
