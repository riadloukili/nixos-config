# GRUB for legacy-BIOS (or hybrid BIOS+EFI) machines, e.g. cloud VMs.
# The disk layout (modules/hardware/disko/cloud-bios.nix) provides the
# BIOS boot partition; grub installs to every disko disk.
{
  flake.modules.nixos.core-boot-grub = {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      # disko fills `boot.loader.grub.devices` from `disk.<n>.device`.
    };
  };
}
