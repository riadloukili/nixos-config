{ mods, ... }:
{
  flake.modules.nixos."hosts/apollo/disk" = {
    imports = [ mods.nixos.disko.server-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
      swapSize = "8G";
    };
  };
}
