# Mango (mangowm, dwl-based) from its flake.
{ config, inputs, ... }:
let
  aspects = config.flake.modules;
in
{
  flake.modules.nixos.desktop-mango =
    { config, lib, ... }:
    {
      imports = [ inputs.mango.nixosModules.mango ];
      options.my.desktop.mango.enable = lib.mkEnableOption "Mango";

      config = lib.mkIf config.my.desktop.mango.enable {
        programs.mango.enable = true;
        my.home.modules = [ aspects.homeManager.home-mango ];
      };
    };

  flake.modules.homeManager.home-mango = {
    # Config is hot-edited from the dotfiles checkout (~/dotfiles/mango).
    my.dotfiles.entries = [ "mango" ];
  };
}
