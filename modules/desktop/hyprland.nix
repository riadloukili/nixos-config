# Hyprland (session via uwsm). The config is a dotfiles entry (home/dotfiles.nix):
# ~/.config/hypr from the checkout, else home/defaults/hypr.
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  home-manager.sharedModules = [ { my.dotfiles.entries.hypr.default = ../../home/defaults/hypr; } ];
}
