# NetworkManager + Bluetooth for roaming machines.
{
  flake.modules.nixos.desktop-network = {
    networking.networkmanager.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
