# 2-in-1 / touchscreen hardware: rotation sensor, touch input, on-screen keyboard.
# Rotating the desktop with it is desktop/autorotate.
{
  flake.modules.nixos."hardware/convertible" =
    { pkgs, ... }:
    {
      hardware.sensor.iio.enable = true; # iio-sensor-proxy: accelerometer over D-Bus
      services.libinput.enable = true;
      environment.systemPackages = [ pkgs.wvkbd ];
    };
}
