# Firmware updates on physical machines: `fwupdmgr refresh && fwupdmgr update`
# (LVFS). The X13 Yoga's BIOS ships USB-C/Thunderbolt fixes this way.
{
  flake.modules.nixos."hardware/firmware" = {
    services.fwupd.enable = true;
  };
}
