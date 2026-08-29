# nixosConfigurations.<name> for every hosts/<provider>/<name>/.
#
# A host directory registers three aspects (see hosts/home/eleuthia):
#   default.nix   hosts/<name>/default    the machine: profiles + users + options
#   hardware.nix  hosts/<name>/hardware   generated hardware config
#   disko.nix     hosts/<name>/disk       disk layout (imports a src/disko/* aspect)
# The live ISO (src/outputs/iso.nix) reuses hosts/<name>/default without the other two.
{
  inputs,
  lib,
  mods,
  hosts,
  ...
}:
let
  mkHost =
    host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = hosts.baseModules host ++ [
        mods.nixos.hosts.${host.name}.default
        mods.nixos.hosts.${host.name}.hardware
        mods.nixos.hosts.${host.name}.disk
      ];
    };
in
{
  flake.nixosConfigurations = lib.listToAttrs (
    map (h: lib.nameValuePair h.name (mkHost h)) hosts.all
  );
}
