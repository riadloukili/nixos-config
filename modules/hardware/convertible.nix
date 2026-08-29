# 2-in-1 / touchscreen: rotation sensor, on-screen keyboard.
{
  flake.modules.nixos.hardware-convertible =
    { pkgs, ... }:
    {
      hardware.sensor.iio.enable = true;
      services.libinput.enable = true;
      environment.systemPackages = with pkgs; [
        wvkbd
        iio-hyprland
      ];
    };
}
