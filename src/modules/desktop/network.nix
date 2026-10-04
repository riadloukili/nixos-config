# NetworkManager + Bluetooth for roaming machines.
{
  flake.modules.nixos."desktop/network" = {
    networking.networkmanager.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    # No blueman: it exists only for its tray applet (an XDG autostart entry),
    # and caelestia's shell owns the bluetooth UI. bluetoothctl is still there.
  };
}
