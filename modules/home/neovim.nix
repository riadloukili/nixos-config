# Neovim for the user: the `nvim` wrapper (modules/wrappers/nvim.nix), which
# loads its config from the dotfiles checkout. No home-manager neovim module
# (it would generate an init.lua).
{ config, ... }:
{
  flake.modules.homeManager.home-neovim =
    { pkgs, ... }:
    {
      home = {
        packages = [ (config.flake.wrappers.nvim.wrap { inherit pkgs; }) ];
        sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };
      };
    };
}
