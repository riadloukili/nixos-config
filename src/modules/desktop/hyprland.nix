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
      # The uwsm session is the one that owns graphical-session.target (portals,
      # user services, env import); the plain "hyprland" entry starts none of that.
      services.displayManager.defaultSession = "hyprland-uwsm";
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
