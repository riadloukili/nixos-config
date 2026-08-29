# GRUB for BIOS / hybrid machines (cloud VMs); pair with disko/cloud-bios.nix,
# which provides the BIOS boot partition. disko fills grub.devices.
{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
}
