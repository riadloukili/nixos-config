# Wrapped CLI programs (wrappers/*.nix) for the user. zsh is the login shell (modules/shell.nix).
{
  flake.modules.homeManager."wrappers" =
    { inputs, pkgs, ... }:
    {
      home.packages = map (w: w.wrap { inherit pkgs; }) (
        with inputs.self.wrappers;
        [
          tmux
          git
          btop
        ]
      );
    };
}
