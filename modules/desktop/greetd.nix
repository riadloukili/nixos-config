# greetd + tuigreet: lists every installed Wayland session and remembers
# the last user/session choice.
{
  flake.modules.nixos.desktop-greetd =
    { config, pkgs, ... }:
    let
      sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
    in
    {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session.command = builtins.concatStringsSep " " [
          "${pkgs.tuigreet}/bin/tuigreet"
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--sessions ${sessions}"
        ];
      };
      # Fingerprint prompts break the text greeter; password (or key) there.
      security.pam.services.greetd.fprintAuth = false;
    };
}
