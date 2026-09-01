# GRUB for BIOS / hybrid machines (cloud VMs); pair with src/disko/cloud-bios.nix,
# which provides the BIOS boot partition. disko fills grub.devices.
{
  flake.modules.nixos."boot/grub" = {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 10;
    };
  };
}
