# Bluetooth.
{
  flake.modules.nixos.desktop-bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
