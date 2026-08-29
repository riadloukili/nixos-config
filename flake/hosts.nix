# Discovers hosts/<provider>/<name>/ and builds nixosConfigurations.<name>.
#
# A host directory contains:
#   default.nix   the machine: imports profiles + users, sets options
#   hardware.nix  generated hardware config (kernel modules, cpu, ...)
#   disko.nix     disk layout (a call to one of ../disko/*.nix)
# hardware.nix and disko.nix are added here, not by default.nix, so the
# live ISO (flake/iso.nix) can reuse default.nix without them.
{ inputs, lib, ... }:
let
  hostsDir = ../hosts;
  isDir = _: type: type == "directory";
  providers = lib.attrNames (lib.filterAttrs isDir (builtins.readDir hostsDir));
  hosts = lib.concatMap (
    provider:
    map (name: {
      inherit name provider;
      dir = hostsDir + "/${provider}/${name}";
    }) (lib.attrNames (lib.filterAttrs isDir (builtins.readDir (hostsDir + "/${provider}"))))
  ) providers;

  # Modules every host gets, independent of profiles.
  baseModules = host: [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    {
      networking.hostName = host.name;
      nixpkgs.hostPlatform = "x86_64-linux";
      environment.variables.CLOUD_PROVIDER = host.provider;
      _module.args.hostDir = host.dir;
    }
  ];

  mkHost =
    host:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = baseModules host ++ [
        (host.dir + "/default.nix")
        (host.dir + "/hardware.nix")
        (host.dir + "/disko.nix")
      ];
    };
in
{
  flake = {
    nixosConfigurations = lib.listToAttrs (map (h: lib.nameValuePair h.name (mkHost h)) hosts);
    # Used by flake/iso.nix.
    lib = {
      inherit hosts baseModules;
    };
  };
}
