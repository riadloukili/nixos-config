# Wayland desktop for laptops and desktops: Hyprland today, room for another
# compositor (add a src/modules/desktop/<name>.nix and import it here).
{ mods, ... }:
{
  flake.modules.nixos."profiles/desktop" = {
    imports = with mods.nixos; [
      profiles.base
      docker
      desktop.sddm
      desktop.hyprland
      desktop.tools
      desktop.audio
      desktop.fonts
      desktop.keyboard
      desktop.network
      desktop.envfs
      desktop.flatpak
      hardware.firmware
      nix-ld
    ];
  };
}
