# nixpkgs / home-manager pairs a host can pick with `channel`.
{ inputs, lib, ... }:
{
  options.flake.channels = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          nixpkgs = lib.mkOption { type = lib.types.raw; };
          home-manager = lib.mkOption { type = lib.types.raw; };
        };
      }
    );
    description = "Named nixpkgs + home-manager input pairs.";
  };

  config.flake.channels = {
    unstable = {
      inherit (inputs) nixpkgs home-manager;
    };
    stable = {
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
    };
  };
}
