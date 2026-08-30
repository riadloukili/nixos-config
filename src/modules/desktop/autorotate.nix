# Auto-rotate the Hyprland display (and touch/pen input) with the accelerometer,
# only while the tablet-mode switch is on (2-in-1 folded past 180°). Needs
# hardware/convertible (iio-sensor-proxy) on the host.
{
  flake.modules.nixos."desktop/autorotate" =
    { pkgs, ... }:
    let
      # Follows iio-sensor-proxy's accelerometer and rotates the Hyprland output
      # (plus touch/pen input) to match — only while the tablet-mode switch is on
      # (folded past 180°); back to upright when it turns off. iio-hyprland exists
      # but aborts whenever an unrelated D-Bus signal arrives, hence a script.
      autorotate = pkgs.writeShellApplication {
        name = "hypr-autorotate";
        runtimeInputs = with pkgs; [
          iio-sensor-proxy
          hyprland
          jq
          coreutils
          evtest
        ];
        text = ''
          output=''${1:-$(hyprctl monitors -j | jq -r 'map(select(.name | startswith("eDP")))[0].name // .[0].name')}

          # Input devices exposing SW_TABLET_MODE (capabilities/sw bit 1).
          switches=()
          for d in /sys/class/input/event*; do
            sw=$(cat "$d/device/capabilities/sw" 2>/dev/null || echo 0)
            if (( 0x$sw & 2 )); then switches+=("/dev/input/$(basename "$d")"); fi
          done
          tablet=0
          for dev in "''${switches[@]}"; do
            evtest --query "$dev" EV_SW SW_TABLET_MODE >/dev/null 2>&1 || tablet=1  # exit 10 = switch on
          done
          echo "tablet-mode switches: ''${switches[*]:-none}; tablet=$tablet"

          orientation=normal
          apply() {
            local t
            case "$orientation" in
              normal) t=0 ;; left-up) t=1 ;; bottom-up) t=2 ;; right-up) t=3 ;; *) return ;;
            esac
            [ "$tablet" = 1 ] || t=0   # laptop mode: always upright
            hyprctl --batch "keyword monitor $output,transform,$t ; keyword input:touchdevice:transform $t ; keyword input:tablet:transform $t" >/dev/null
          }

          {
            stdbuf -oL monitor-sensor --accel &
            for dev in "''${switches[@]}"; do stdbuf -oL evtest "$dev" & done
            wait
          } | while read -r line; do
            case "$line" in
              *"Has accelerometer (orientation: "*) o=''${line#*orientation: }; orientation=''${o%%,*}; apply ;;
              *"orientation changed: "*) orientation=''${line##*: }; apply ;;
              *"(SW_TABLET_MODE), value 1"*) tablet=1; echo "tablet mode on"; apply ;;
              *"(SW_TABLET_MODE), value 0"*) tablet=0; echo "tablet mode off"; apply ;;
            esac
          done
        '';
      };
    in
    {
      # iio-sensor-proxy only lets active local sessions claim the sensor; the
      # service runs outside a session, so allow desktop users.
      security.polkit.extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (action.id.indexOf("net.hadess.SensorProxy.") == 0 && subject.isInGroup("input")) {
            return polkit.Result.YES;
          }
        });
      '';

      environment.systemPackages = [ autorotate ];

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
