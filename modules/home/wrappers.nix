# Installs the wrapped programs (modules/wrappers) for the user and makes the
# wrapped zsh the login shell.
{ config, ... }:
{
  flake.modules.homeManager.home-wrappers =
    { pkgs, ... }:
    {
      home.packages = map (w: w.wrap { inherit pkgs; }) (
        with config.flake.wrappers;
        [
          tmux
          git
          btop
        ]
      );
    };

  flake.modules.nixos.core-zsh-wrapper =
    { pkgs, ... }:
    let
      zsh = config.flake.wrappers.zsh.wrap { inherit pkgs; };
    in
    {
      environment.shells = [ zsh ];
      users.defaultUserShell = zsh;
    };
}
