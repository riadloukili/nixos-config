# Host discovery (plumbing, not an output). Provides the `hosts` argument:
#   hosts.all          [ { name; provider; } ] for every hosts/<provider>/<name>/
#   hosts.baseModules  host: [ modules every host and live image gets ]
# Consumed by src/outputs/hosts.nix and src/outputs/iso.nix.
{ inputs, lib, ... }:
let
  hostsDir = ../../hosts;
  isDir = _: type: type == "directory";
  subdirs = dir: lib.attrNames (lib.filterAttrs isDir (builtins.readDir dir));
in
{
  _module.args.hosts = {
    all = lib.concatMap (
      provider: map (name: { inherit name provider; }) (subdirs (hostsDir + "/${provider}"))
    ) (subdirs hostsDir);

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
  };
}
