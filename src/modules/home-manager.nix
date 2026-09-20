# home-manager wiring (the NixOS module itself is added by src/lib/hosts.nix).
# The dotfiles aspect is the only shared HM module; everything personal lives
# in users/<name>/home.nix.
{ mods, ... }:
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
        sharedModules = [ mods.homeManager.dotfiles ];
      };
    };
}
