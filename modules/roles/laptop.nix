# Personal laptop: Wayland desktop, laptop hardware, no self-updates.
{ config, ... }:
{
  flake.modules.nixos.roles-laptop = {
    imports = with config.flake.modules.nixos; [
      roles-base
      core-boot-systemd
      services-firewall
      services-docker
      hardware-laptop-power
      desktop-compositors
      desktop-greetd
      desktop-pipewire
      desktop-portals
      desktop-fonts
      desktop-keyboard
      desktop-networkmanager
      desktop-bluetooth
    ];
    my.home.modules = with config.flake.modules.homeManager; [
      home-wayland-common
      home-dev
    ];
    my.desktop.compositors = [
      "hyprland"
      "mango"
    ];
  };
}
