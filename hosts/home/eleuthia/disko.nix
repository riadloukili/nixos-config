{
  flake.modules.nixos.host-eleuthia-disk = import ../../../disko/laptop-luks-btrfs.nix {
    device = "/dev/nvme0n1";
    swapSize = "16G";
  };
}
