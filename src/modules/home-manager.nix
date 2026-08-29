# home-manager wiring (the NixOS module itself is added by src/lib/hosts.nix).
# Shared HM aspects go through `home-manager.sharedModules` (profiles/base.nix
# adds dotfiles); everything personal lives in users/<name>/home.nix.
{
  flake.modules.nixos."home-manager" =
    { inputs, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = {
          inherit inputs;
        };
        sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      };
    };
}
