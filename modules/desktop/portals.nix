# XDG desktop portals (Hyprland adds its own on top).
{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
    ];
    config.common.default = [
      "gtk"
      "wlr"
    ];
  };
}
