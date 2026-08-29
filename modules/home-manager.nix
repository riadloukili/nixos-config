# home-manager wiring (the NixOS module itself is added in flake/hosts.nix).
# Profiles add HM modules through `home-manager.sharedModules`.
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
