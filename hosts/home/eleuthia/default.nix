# eleuthia — personal laptop (ThinkPad Yoga, Intel).
{
  imports = [
    ../../../profiles/laptop.nix
    ../../../users/riad.nix
    ../../../modules/boot/systemd-boot.nix
    ../../../modules/hardware/intel.nix
    ../../../modules/hardware/thinkpad.nix
    ../../../modules/hardware/fingerprint.nix
    ../../../modules/hardware/convertible.nix
  ];

  system.stateVersion = "26.11";
  my.repo.localPath = "/home/riad/personal/nixos-config";
}
