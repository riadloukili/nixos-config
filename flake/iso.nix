# Live / installer images:
#   nix build .#iso-<host>   that host's config as a live system + `install-<host>`
#                            (offline: its disko script, then nixos-install from
#                            the closure on the image)
#   nix build .#iso-server   generic live image with the server profile
#   nix build .#iso-desktop  generic live image with the desktop profile
{
  config,
  inputs,
  lib,
  mods,
  ...
}:
let
  mkIso =
    name: modules:
    (inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = modules ++ [
        mods.nixos.installer.base
        { my.installer.name = name; }
      ];
    }).config.system.build.isoImage;

  generic = lib.genAttrs [ "server" "desktop" ] (
    profile:
    mkIso profile (
      config.flake.lib.baseModules {
        name = "nixos-${profile}";
        provider = "live";
      }
      ++ [
        mods.nixos.profiles.${profile}
        mods.nixos.users.riad
      ]
    )
  );

  perHost = lib.listToAttrs (
    map (
      host:
      let
        target = config.flake.nixosConfigurations.${host.name};
      in
      lib.nameValuePair host.name (
        mkIso host.name (
          config.flake.lib.baseModules host
          ++ [
            mods.nixos.hosts.${host.name}.default
            mods.nixos.installer.target
            {
              my.installer.target = {
                toplevel = target.config.system.build.toplevel;
                diskoScript = target.config.system.build.diskoScript;
                disks = lib.mapAttrsToList (_: d: d.device) target.config.disko.devices.disk;
              };
            }
          ]
        )
      )
    ) config.flake.lib.hosts
  );
in
{
  perSystem.packages = lib.mapAttrs' (n: v: lib.nameValuePair "iso-${n}" v) (generic // perHost);
}
