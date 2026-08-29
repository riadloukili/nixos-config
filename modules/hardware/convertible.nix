# 2-in-1 / touchscreen: auto-rotation sensor, on-screen keyboard, touch tools.
{
  flake.modules.nixos.hardware-convertible =
    { pkgs, ... }:
    {
      hardware.sensor.iio.enable = true;
      services.libinput.enable = true;
      environment.systemPackages = with pkgs; [
        wvkbd # on-screen keyboard (wvkbd-mobintl)
        iio-hyprland # auto-rotate helper for Hyprland
        wl-clipboard
      ];
    };
}
