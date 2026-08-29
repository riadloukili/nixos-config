# pre-commit hooks (installed by the devShell, run by `nix flake check`).
{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem.pre-commit.settings = {
    hooks = {
      treefmt.enable = true;
      deadnix.enable = true;
      statix.enable = true;
      typos = {
        enable = true;
        settings.configPath = ".typos.toml";
      };
      yamllint.enable = true;
      markdownlint = {
        enable = true;
        settings.configuration = {
          MD013 = false;
          MD033 = false;
        };
      };
      check-added-large-files.enable = true;
      check-merge-conflicts.enable = true;
      end-of-file-fixer.enable = true;
      trim-trailing-whitespace.enable = true;
    };
    excludes = [
      "secrets/.*\\.yaml"
      "wrappers/defaults/p10k\\.zsh"
      "home/defaults/.*"
    ];
  };
}
