# `nix develop` / direnv: tools to build, push and manage secrets, plus the
# pre-commit hooks.
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
            mkpasswd
            nixd
            qemu
            inputs.disko.packages.${system}.disko
            config.treefmt.build.wrapper
          ]
          ++ config.pre-commit.settings.enabledPackages;
        shellHook = config.pre-commit.shellHook;
      };
    };
}
