{ mods, ... }:
{
  flake.modules.nixos."hosts/eleuthia/disk" = {
    imports = [ mods.nixos.disko.laptop-luks-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
      swapSize = "16G";
    };
  };
}
