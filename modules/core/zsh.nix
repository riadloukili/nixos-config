# Registers zsh as a valid login shell. The actual shell config is the `zsh`
# wrapper (modules/wrappers/zsh), installed by core-zsh-wrapper.
{
  flake.modules.nixos.core-zsh = {
    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
