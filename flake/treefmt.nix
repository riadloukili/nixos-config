# `nix fmt` and the formatting check in `nix flake check`.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
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
      "wrappers/defaults/p10k.zsh"
      "home/defaults/*"
    ];
  };
}
