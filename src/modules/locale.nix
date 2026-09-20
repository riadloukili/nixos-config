# Time zone and locale.
{
  flake.modules.nixos."locale" =
    { config, lib, ... }:
    {
      time.timeZone = lib.mkDefault "America/Toronto";
      i18n.defaultLocale = "en_US.UTF-8";

      # glibc resolves a TZ *name* under TZDIR, which defaults to the
      # /usr/share/zoneinfo we don't have; without this `TZ=America/Toronto`
      # parses as a POSIX string ("America", +0000) instead of the zone.
      environment.sessionVariables.TZDIR = "/etc/zoneinfo";

      # Qt reads /etc/timezone first and otherwise tries to name the zone from
      # the /etc/localtime target, which is a store path it cannot map — hence
      # "Unable to determine system time zone" in Qt apps (FreeCAD).
      environment.etc.timezone = lib.mkIf (config.time.timeZone != null) {
        text = "${config.time.timeZone}\n";
      };
    };
}
