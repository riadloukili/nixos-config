# Wayland desktop (Hyprland) for laptops and desktops.
{
  imports = [
    ./base.nix
    ../modules/firewall.nix
    ../modules/docker.nix
    ../modules/desktop/greetd.nix
    ../modules/desktop/hyprland.nix
    ../modules/desktop/audio.nix
    ../modules/desktop/portals.nix
    ../modules/desktop/fonts.nix
    ../modules/desktop/keyboard.nix
    ../modules/desktop/network.nix
  ];

  home-manager.sharedModules = [
    ../home/dev.nix
    ../home/wayland.nix
    ../home/desktop.nix
  ];
}
