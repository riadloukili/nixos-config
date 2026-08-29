# pre-commit hooks, installed by the devShell and run by `nix flake check`.
{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem = {
    pre-commit.settings = {
      hooks = {
        treefmt.enable = true; # wired to the treefmt-nix wrapper automatically
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
            MD013 = false; # line length
            MD033 = false; # inline html
          };
        };
        check-added-large-files.enable = true;
        check-merge-conflicts.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;
      };
      excludes = [
        "secrets/.*\\.yaml"
      ];
    };
  };
}
