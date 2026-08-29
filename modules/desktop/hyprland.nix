# Hyprland: the NixOS half installs the compositor, portal and session
# entry (via uwsm); the home half only hands `~/.config/hypr` to the
# dotfiles checkout — the config is hot-edited, not generated.
{ config, ... }:
let
  aspects = config.flake.modules;
in
{
  flake.modules.nixos.desktop-hyprland =
    { config, lib, ... }:
    {
      options.my.desktop.hyprland.enable = lib.mkEnableOption "Hyprland";

      config = lib.mkIf config.my.desktop.hyprland.enable {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
        };
        my.home.modules = [ aspects.homeManager.home-hyprland ];
      };
    };

  flake.modules.homeManager.home-hyprland = {
    my.dotfiles.entries = [ "hypr" ];
  };
}
