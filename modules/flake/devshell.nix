# `nix develop` / direnv: every tool needed to build, deploy and manage
# secrets, plus the pre-commit hooks.
{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages =
          with pkgs;
          [
            just
            nh
            nix-output-monitor
            nvd
            sops
            age
            ssh-to-age
            secretspec
            nixd
            nixfmt
            statix
            deadnix
            qemu
          ]
          ++ [
            inputs.deploy-rs.packages.${system}.deploy-rs
            inputs.disko.packages.${system}.disko
            inputs.disko.packages.${system}.disko-install
            config.treefmt.build.wrapper
          ]
          ++ config.pre-commit.settings.enabledPackages;

        shellHook = ''
          ${config.pre-commit.shellHook}
          echo "nixos-config devshell — run 'just' to list tasks"
        '';
      };
    };
}
