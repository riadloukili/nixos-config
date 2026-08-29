# Hyprland session (via uwsm) + portals. Config comes from the user's dotfiles.
# A second compositor (e.g. mango) would be another file like this one,
# imported by profiles/desktop.nix; SDDM lists every installed session.
{
  flake.modules.nixos."desktop/hyprland" =
    { pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [
          "hyprland"
          "gtk"
        ];
      };
    };
}
