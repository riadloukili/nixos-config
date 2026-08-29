# The dendritic registry. Every file under modules/, profiles/, users/, home/,
# hosts/, disko/ and installer/ is a flake-parts module that registers aspects
# named after their path:
#
#   { flake.modules.nixos."hardware/thinkpad" = { ... }; }   # a NixOS module
#   { flake.modules.homeManager.cli = { ... }; }             # a home-manager module
#
# They come back to every file as the `mods` argument, nested by path, so
# composition is by name: `imports = with mods.nixos; [ profiles.base docker hardware.thinkpad ];`
# Each aspect is wrapped with a `key`, which makes the module system
# deduplicate it — importing the same aspect from several profiles is fine.
{
  config,
  inputs,
  lib,
  ...
}:
let
  keyed = lib.mapAttrs (
    class:
    lib.mapAttrs (
      name: module: {
        key = "${class}/${name}";
        imports = [ module ];
      }
    )
  ) config.flake.modules;

  nest = lib.mapAttrs (
    _: aspects:
    lib.foldlAttrs (
      acc: name: module:
      lib.recursiveUpdate acc (lib.setAttrByPath (lib.splitString "/" name) module)
    ) { } aspects
  );
in
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
  _module.args.mods = nest keyed;
}
