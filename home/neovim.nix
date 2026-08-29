# Neovim = the `nvim` wrapper (wrappers/nvim.nix), which loads the dotfiles
# nvim/ entry or the LazyVim starter in home/defaults/nvim.
{ inputs, pkgs, ... }:
{
  home = {
    packages = [ (inputs.self.wrappers.nvim.wrap { inherit pkgs; }) ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
}
