# Hyprland (session via uwsm). Both halves of the feature live here: the
# NixOS part installs it, the home part hands ~/.config/hypr to the dotfiles
# layer (checkout override, else home/defaults/hypr).
{ mods, ... }:
{
  flake.modules.nixos."desktop/hyprland" = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    home-manager.sharedModules = [ mods.homeManager.hyprland ];
  };

  flake.modules.homeManager.hyprland = {
    my.dotfiles.entries.hypr.default = ../../home/defaults/hypr;
  };
}
