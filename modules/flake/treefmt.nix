# `nix fmt` and the formatting check (part of `nix flake check`).
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      flakeCheck = true;
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
      ];
    };
  };
}
