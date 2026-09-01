# nixosConfigurations.<name> for every hosts/<provider>/<name>/.
#
# A host directory registers three aspects (see hosts/home/eleuthia):
#   default.nix   hosts/<name>/default    the machine: profiles + users + options
#   hardware.nix  hosts/<name>/hardware   generated hardware config
#   disko.nix     hosts/<name>/disk       disk layout (imports a src/disko/* aspect)
# The live ISO (src/outputs/iso.nix) reuses hosts/<name>/default without the other two.
{
  lib,
  mods,
  hosts,
  ...
}:
let
  aspect =
    host: file: attr:
    mods.nixos.hosts.${host.name}.${attr}
      or (throw "hosts/${host.provider}/${host.name}/${file} is missing (or does not register hosts/${host.name}/${attr})");

  mkHost =
    host:
    hosts.mkSystem (
      hosts.baseModules host
      ++ [
        (aspect host "default.nix" "default")
        (aspect host "hardware.nix" "hardware")
        (aspect host "disko.nix" "disk")
      ]
    );
in
{
  flake.nixosConfigurations = lib.listToAttrs (
    map (h: lib.nameValuePair h.name (mkHost h)) hosts.all
  );
}
