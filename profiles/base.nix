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
      packages
      gc
      home-manager
      secrets
    ];
    home-manager.sharedModules = with mods.homeManager; [
      cli
      neovim
      wrappers
      dotfiles
      sops
    ];
  };
}
