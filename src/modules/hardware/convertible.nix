# 2-in-1 / touchscreen: rotation sensor, auto-rotate under Hyprland, on-screen keyboard.
{
  flake.modules.nixos."hardware/convertible" =
    { pkgs, ... }:
    let
      # Follows iio-sensor-proxy's accelerometer and rotates the Hyprland output
      # (plus touch/pen input) to match. iio-hyprland exists but aborts whenever
      # an unrelated D-Bus signal arrives, so this does the same job in shell.
      autorotate = pkgs.writeShellApplication {
        name = "hypr-autorotate";
        runtimeInputs = with pkgs; [
          iio-sensor-proxy
          hyprland
          jq
          coreutils
        ];
        text = ''
          output=''${1:-$(hyprctl monitors -j | jq -r 'map(select(.name | startswith("eDP")))[0].name // .[0].name')}
          rotate() {
            case "$1" in
              normal) t=0 ;; left-up) t=1 ;; bottom-up) t=2 ;; right-up) t=3 ;; *) return ;;
            esac
            hyprctl --batch "keyword monitor $output,transform,$t ; keyword input:touchdevice:transform $t ; keyword input:tablet:transform $t" >/dev/null
          }
          stdbuf -oL monitor-sensor --accel | while read -r line; do
            case "$line" in
              *"Has accelerometer (orientation: "*) o=''${line#*orientation: }; rotate "''${o%%,*}" ;;
              *"orientation changed: "*) rotate "''${line##*: }" ;;
            esac
          done
        '';
      };
    in
    {
      hardware.sensor.iio.enable = true; # iio-sensor-proxy: accelerometer over D-Bus
      # iio-sensor-proxy only lets active local sessions claim the sensor; the
      # rotate service below runs outside a session, so allow desktop users.
      security.polkit.extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (action.id.indexOf("net.hadess.SensorProxy.") == 0 && subject.isInGroup("input")) {
            return polkit.Result.YES;
          }
        });
      '';
      services.libinput.enable = true;
      environment.systemPackages = [
        pkgs.wvkbd
        autorotate
      ];

      # Bound to the graphical session; uwsm exports HYPRLAND_INSTANCE_SIGNATURE
      # to the user manager, so no line is needed in the Hyprland dotfiles.
      systemd.user.services.hypr-autorotate = {
        description = "Auto-rotate the Hyprland display with the accelerometer";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${autorotate}/bin/hypr-autorotate";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
