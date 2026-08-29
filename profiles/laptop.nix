# Desktop + laptop hardware behaviour.
{ mods, ... }:
{
  flake.modules.nixos.profile-laptop = {
    imports = with mods.nixos; [
      profile-desktop
      hardware-laptop-power
    ];
  };
}
