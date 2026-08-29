# Login shell: the wrapped zsh (wrappers/zsh.nix) for every user; passwordless sudo for wheel.
{ inputs, pkgs, ... }:
let
  zsh = inputs.self.wrappers.zsh.wrap { inherit pkgs; };
in
{
  programs.zsh.enable = true;
  environment.shells = [ zsh ];
  users.defaultUserShell = zsh;
  environment.pathsToLink = [ "/share/zsh" ];
  security.sudo.wheelNeedsPassword = false;
}
