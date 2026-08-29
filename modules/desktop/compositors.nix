# Which Wayland compositors a desktop host installs. Each name maps to a
# `desktop-<name>` NixOS aspect (which pulls in its `home-<name>` half);
# every enabled compositor shows up as a session in the greeter.
{ config, ... }:
let
  aspects = config.flake.modules;
in
{
  flake.modules.nixos.desktop-compositors =
    { config, lib, ... }:
    let
      cfg = config.my.desktop;
    in
    {
      imports = [
        aspects.nixos.desktop-hyprland
        aspects.nixos.desktop-mango
      ];

      options.my.desktop.compositors = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "hyprland"
            "mango"
          ]
        );
        default = [ ];
        description = "Compositors to install and offer at login.";
      };

      config = lib.mkIf (cfg.compositors != [ ]) {
        my.desktop.hyprland.enable = lib.elem "hyprland" cfg.compositors;
        my.desktop.mango.enable = lib.elem "mango" cfg.compositors;
        my.home.modules = [ aspects.homeManager.home-desktop-session ];
      };
    };
}
