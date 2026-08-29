# Wayland desktop (Hyprland) for laptops and desktops.
{ mods, ... }:
{
  flake.modules.nixos.profile-desktop = {
    imports = with mods.nixos; [
      profile-base
      firewall
      docker
      desktop-greetd
      desktop-hyprland
      desktop-audio
      desktop-portals
      desktop-fonts
      desktop-keyboard
      desktop-network
    ];
    home-manager.sharedModules = with mods.homeManager; [
      dev
      wayland
      desktop
    ];
  };
}
