# Every machine.
{ mods, ... }:
{
  flake.modules.nixos."profiles/base" = {
    imports = with mods.nixos; [
      nix
      locale
      nh
      ssh
      shell
      gc
      home-manager
      secrets
    ];
    home-manager.sharedModules = [ mods.homeManager.dotfiles ];
  };
}
