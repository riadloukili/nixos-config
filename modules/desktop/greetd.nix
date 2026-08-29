# greetd + tuigreet: lists every installed Wayland session, remembers the last choice.
{
  flake.modules.nixos.desktop-greetd =
    { config, pkgs, ... }:
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
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
      };
      security.pam.services.greetd.fprintAuth = false; # fingerprint prompts break the text greeter
    };
}
