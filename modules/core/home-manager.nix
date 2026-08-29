# home-manager wiring. The home-manager NixOS module itself is added per host
# by modules/flake/hosts.nix (it depends on the host's channel).
#
# Roles and hosts add home-manager aspects to `my.home.modules`; every user
# defined under modules/core/users imports that list.
{ inputs, ... }:
{
  flake.modules.nixos.core-home-manager =
    { lib, ... }:
    {
      options.my.home.modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
        description = "home-manager modules applied to every managed user on this host.";
      };

      config.home-manager = {
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
