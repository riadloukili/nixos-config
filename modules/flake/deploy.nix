# deploy-rs nodes for every host with `deploy` set, plus the schema checks.
{
  config,
  inputs,
  lib,
  ...
}:
let
  deployable = lib.filterAttrs (_: h: h.deploy != null) config.flake.hosts;

  mkNode = name: host: {
    inherit (host.deploy) hostname sshUser remoteBuild;
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.${host.system}.activate.nixos config.flake.nixosConfigurations.${name};
    };
  };
in
{
  flake.deploy = {
    autoRollback = true;
    magicRollback = true;
    nodes = lib.mapAttrs mkNode deployable;
  };

  perSystem =
    { system, ... }:
    {
      checks = lib.optionalAttrs (inputs.deploy-rs.lib ? ${system}) (
        inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy
      );
    };
}
