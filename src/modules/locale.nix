# Time zone and locale.
{
  flake.modules.nixos."locale" =
    { lib, ... }:
    {
      time.timeZone = lib.mkDefault "America/Toronto";
      i18n.defaultLocale = "en_US.UTF-8";
    };
}
