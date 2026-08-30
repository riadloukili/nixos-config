# 2-in-1 / touchscreen: rotation sensor, auto-rotate under Hyprland, on-screen keyboard.
{
  flake.modules.nixos."hardware/convertible" =
    { pkgs, ... }:
    {
      hardware.sensor.iio.enable = true; # iio-sensor-proxy: accelerometer over D-Bus
      services.libinput.enable = true;
      environment.systemPackages = with pkgs; [
        wvkbd
        iio-hyprland
      ];

      # Rotates the Hyprland output to follow the accelerometer. A user service
      # bound to the graphical session (uwsm exports HYPRLAND_INSTANCE_SIGNATURE
      # to the user manager), so it needs no line in the Hyprland dotfiles.
      systemd.user.services.iio-hyprland = {
        description = "Auto-rotate the Hyprland display with the accelerometer";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.iio-hyprland}/bin/iio-hyprland";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
