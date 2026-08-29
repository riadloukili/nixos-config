# Installer / live ISOs:
#   packages.<system>.iso-server      generic live image with the server role
#   packages.<system>.iso-desktop     generic live image with the laptop role
#   packages.<system>.iso-<host>      that host's software config as a live
#                                     system + `install-<host>` (offline, disko)
# Build with `just iso <target>`.
{
  config,
  inputs,
  lib,
  ...
}:
let
  hosts = config.flake.hosts;
  nixosModules = config.flake.modules.nixos;

  # Generic images: base modules of a synthetic host + a role.
  generic = {
    server = {
      role = nixosModules.roles-server;
      channel = "unstable";
    };
    desktop = {
      role = nixosModules.roles-laptop;
      channel = "unstable";
    };
  };

  mkGenericIso =
    system: variant: spec:
    let
      pseudoHost = {
        inherit system;
        inherit (spec) channel;
        provider = "live";
        stateVersion = "26.11";
        _name = "nixos-${variant}";
      };
    in
    (config.flake.channels.${spec.channel}.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = config.flake.lib.mkHostBaseModules pseudoHost ++ [
        spec.role
        nixosModules.installer-base
        { my.installer.isoName = "nixos-${variant}"; }
      ];
    }).config.system.build.isoImage;

  mkHostIso =
    name: host:
    let
      target = config.flake.nixosConfigurations.${name};
    in
    (config.flake.channels.${host.channel}.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules =
        config.flake.lib.mkHostBaseModules host
        ++ host.modules
        ++ [
          nixosModules.installer-base
          nixosModules.installer-target
          {
            my.installer = {
              isoName = "nixos-${name}";
              target = {
                inherit name;
                toplevel = target.config.system.build.toplevel;
                diskoScript = target.config.system.build.diskoScript;
                disks = lib.mapAttrsToList (_: d: d.device) target.config.disko.devices.disk;
              };
            };
          }
        ];
    }).config.system.build.isoImage;
in
{
  perSystem =
    { system, ... }:
    {
      packages =
        lib.mapAttrs' (
          variant: spec: lib.nameValuePair "iso-${variant}" (mkGenericIso system variant spec)
        ) generic
        // lib.mapAttrs' (name: host: lib.nameValuePair "iso-${name}" (mkHostIso name host)) (
          lib.filterAttrs (_: h: h.system == system) hosts
        );
    };
}
