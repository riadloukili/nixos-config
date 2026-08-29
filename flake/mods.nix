# The dendritic registry. Every file under modules/, profiles/, users/, home/,
# hosts/ and installer/ is a flake-parts module that registers aspects:
#
#   { flake.modules.nixos.docker = { ... }; }            # a NixOS module
#   { flake.modules.homeManager.cli = { ... }; }         # a home-manager module
#
# They are handed back to every file as the `mods` argument, so composition
# is by name: `imports = with mods.nixos; [ profile-base docker ];`.
# Each aspect is wrapped with a `key`, which makes the module system
# deduplicate it — importing the same aspect from several profiles is fine.
{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  _module.args.mods = lib.mapAttrs (
    class:
    lib.mapAttrs (
      name: module: {
        key = "${class}/${name}";
        imports = [ module ];
      }
    )
  ) config.flake.modules;
}
