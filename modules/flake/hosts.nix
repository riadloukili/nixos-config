# Host inventory. Each modules/hosts/<name>/default.nix registers itself in
# `flake.hosts.<name>`; this file turns the inventory into
# `nixosConfigurations.<name>`. Deploy nodes and installer ISOs are derived
# from the same inventory (deploy.nix, installers.nix).
{
  config,
  inputs,
  lib,
  ...
}:
let
  hostType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        system = lib.mkOption {
          type = lib.types.str;
          default = "x86_64-linux";
        };
        channel = lib.mkOption {
          type = lib.types.enum (lib.attrNames config.flake.channels);
          default = "unstable";
          description = "Which nixpkgs/home-manager pair to build with.";
        };
        provider = lib.mkOption {
          type = lib.types.str;
          default = "home";
          example = "hetzner";
          description = "Where the machine lives; exported as $CLOUD_PROVIDER for the prompt.";
        };
        stateVersion = lib.mkOption {
          type = lib.types.str;
          description = "NixOS release the host was first installed with. Never bump.";
        };
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          description = "Software configuration (roles + host aspect). Also used by the host's live ISO.";
        };
        hardwareModules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          description = "Hardware + disk configuration. Excluded from the live ISO.";
        };
        deploy = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                hostname = lib.mkOption { type = lib.types.str; };
                sshUser = lib.mkOption {
                  type = lib.types.str;
                  default = "riad";
                };
                remoteBuild = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                };
              };
            }
          );
          default = null;
          description = "deploy-rs target; null for pull-only hosts.";
        };
        iso = lib.mkOption {
          type = lib.types.enum [
            "server"
            "desktop"
          ];
          default = "server";
          description = "Which installer base the host's live ISO is built on.";
        };
        _name = lib.mkOption {
          type = lib.types.str;
          default = name;
          internal = true;
        };
      };
    }
  );

  # Modules every host gets regardless of role.
  baseModules =
    host:
    let
      channel = config.flake.channels.${host.channel};
    in
    [
      channel.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      config.flake.modules.nixos.core-overlays
      {
        networking.hostName = host._name;
        nixpkgs.hostPlatform = host.system;
        system.stateVersion = host.stateVersion;
        environment.variables.CLOUD_PROVIDER = host.provider;
      }
    ];

  mkHost =
    host:
    config.flake.channels.${host.channel}.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = baseModules host ++ host.modules ++ host.hardwareModules;
    };
in
{
  options.flake.hosts = lib.mkOption {
    type = lib.types.attrsOf hostType;
    default = { };
    description = "Machine inventory.";
  };

  config.flake = {
    nixosConfigurations = lib.mapAttrs (_: mkHost) config.flake.hosts;
    # Exposed for installers.nix (same base, without hardware).
    lib.mkHostBaseModules = baseModules;
  };
}
