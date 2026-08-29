# hosts/<provider>/<name>/ → nixosConfigurations.<name>.
#
# A host directory registers three aspects (see hosts/home/eleuthia):
#   default.nix   hosts/<name>/default    the machine: profiles + users + options
#   hardware.nix  hosts/<name>/hardware   generated hardware config
#   disko.nix     hosts/<name>/disk       disk layout (imports a disko/* aspect)
# The live ISO (flake/iso.nix) reuses hosts/<name>/default without the other two.
{
  inputs,
  lib,
  mods,
  ...
}:
let
  hostsDir = ../hosts;
  isDir = _: type: type == "directory";
  providers = lib.attrNames (lib.filterAttrs isDir (builtins.readDir hostsDir));
  hosts = lib.concatMap (
    provider:
    map (name: { inherit name provider; }) (
      lib.attrNames (lib.filterAttrs isDir (builtins.readDir (hostsDir + "/${provider}")))
    )
  ) providers;

  # What every host (and live image) gets regardless of profile.
  baseModules = host: [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    {
      networking.hostName = host.name;
      nixpkgs.hostPlatform = "x86_64-linux";
      environment.variables.CLOUD_PROVIDER = host.provider;
    }
  ];

  mkHost =
    host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = baseModules host ++ [
        mods.nixos.hosts.${host.name}.default
        mods.nixos.hosts.${host.name}.hardware
        mods.nixos.hosts.${host.name}.disk
      ];
    };
in
{
  flake = {
    nixosConfigurations = lib.listToAttrs (map (h: lib.nameValuePair h.name (mkHost h)) hosts);
    lib = {
      inherit hosts baseModules;
    }; # used by flake/iso.nix
  };
}
