{ mods, ... }:
{
  flake.modules.nixos.host-apollo-disk = {
    imports = [ mods.nixos.disko-server-btrfs ];
    my.disk = {
      device = "/dev/nvme0n1";
      swapSize = "8G";
    };
  };
}
