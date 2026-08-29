# Wayland desktop for laptops and desktops: Hyprland today, room for another
# compositor (add a modules/desktop/<name>.nix and import it here).
{ mods, ... }:
{
  flake.modules.nixos."profiles/desktop" = {
    imports = with mods.nixos; [
      profiles.base
      firewall
      docker
      desktop.greetd
      desktop.hyprland
      desktop.tools
      desktop.audio
      desktop.fonts
      desktop.keyboard
      desktop.network
    ];
  };
}
