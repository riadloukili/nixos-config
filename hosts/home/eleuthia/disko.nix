{ mods, ... }:
{
  flake.modules.nixos.host-eleuthia-disk = {
    imports = [ mods.nixos.disko-laptop-luks-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
      swapSize = "16G";
    };
  };
}
