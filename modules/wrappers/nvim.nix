# Neovim + the tools a LazyVim config needs, loading the config from the
# dotfiles checkout (`<dotfiles>/nvim`). LazyVim manages plugins itself in
# ~/.local/share/nvim, so the config dir stays plain Neovim.
{ config, lib, ... }:
let
  dot = config.flake.dotfiles;
in
{
  flake.wrappers.nvim =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.neovim ];

      settings.config_directory =
        if dot.store != null then
          "${dot.store}/nvim"
        else
          lib.generators.mkLuaInline "vim.fn.expand('${dot.runtime}/nvim')";

      runtimePkgs = with pkgs; [
        gcc
        gnumake
        nodejs
        ripgrep
        fd
        lazygit
        tree-sitter
        nixd
        nixfmt
        lua-language-server
        stylua
      ];
    };
}
