# Formatting, lints and checks:
#   nix fmt            treefmt (nixfmt, deadnix, statix, yamlfmt, mdformat, taplo, just, shfmt, typos)
#   nix flake check    treefmt check + pre-commit hooks + build of every host
# The devshell installs the same hooks into .git/hooks.
{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        yamlfmt.enable = true;
        mdformat.enable = true;
        taplo.enable = true;
        just.enable = true;
        shfmt.enable = true;
        typos = {
          enable = true;
          configFile = ".typos.toml";
        };
      };
      settings.excludes = [
        "*.lock"
        "secrets/*.yaml"
        "*.png"
        # local-only files (see .git/info/exclude) and installed agent skills
        "keys.txt"
        "riad_ed25519*"
        ".agents/*"
        "skills-lock.json"
      ];
    };

    # treefmt already runs deadnix/statix/typos; only what it does not cover is added.
    pre-commit.settings = {
      hooks = {
        treefmt.enable = true;
        yamllint.enable = true;
        markdownlint = {
          enable = true;
          settings.configuration = {
            MD013 = false;
            MD033 = false;
          };
        };
        check-added-large-files = {
          enable = true;
          args = [ "--maxkb=4096" ]; # the SDDM background image
        };
        check-merge-conflicts.enable = true;
      };
      excludes = [ "secrets/.*\\.yaml" ];
    };

    checks = lib.mapAttrs' (
      name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel
    ) config.flake.nixosConfigurations;
  };
}
