# Desktop + laptop hardware behaviour.
{ mods, ... }:
{
  flake.modules.nixos."profiles/laptop" = {
    imports = with mods.nixos; [
      profiles.desktop
      hardware.laptop-power
    ];
  };
}
