# eleuthia hardware, from `nixos-generate-config --no-filesystems
# --show-hardware-config` on the machine (2026-08-29). Filesystems come from
# disko.nix; laptop/Intel/ThinkPad specifics from src/modules/hardware/*.
{
  flake.modules.nixos."hosts/eleuthia/hardware" =
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
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      boot.kernelModules = [ "kvm-intel" ];
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      hardware.enableRedistributableFirmware = true;
      networking.useDHCP = lib.mkDefault true;
    };
}
