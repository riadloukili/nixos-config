{
  flake.modules.nixos.host-apollo-disk = import ../../../disko/server-btrfs.nix {
    device = "/dev/nvme0n1";
    swapSize = "8G";
  };
}
