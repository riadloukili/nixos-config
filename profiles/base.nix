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
      sudo
      packages
      home-manager
      secrets
    ];
  };
}
