# apollo hardware (Intel, NVMe). Regenerate with
# `nixos-generate-config --no-filesystems --show-hardware-config` after install.
{
  flake.modules.nixos."hosts/apollo/hardware" =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      boot.kernelModules = [ "kvm-intel" ];
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      networking.useDHCP = lib.mkDefault true;
    };
}
