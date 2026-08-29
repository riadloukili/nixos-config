# Neovim + the tools a LazyVim config needs. Config directory: the dotfiles
# checkout's `nvim/` when present, otherwise the LazyVim starter shipped in
# modules/home/defaults/nvim. LazyVim manages plugins itself in ~/.local/share.
{ config, lib, ... }:
let
  dot = config.flake.dotfiles;
  default = ../home/defaults/nvim;
in
{
  flake.wrappers.nvim =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.neovim ];

      settings.config_directory =
        if dot.store != null then
          (if builtins.pathExists "${dot.store}/nvim" then "${dot.store}/nvim" else default)
        else
          lib.generators.mkLuaInline ''
            (function()
              local d = vim.fn.expand('${dot.runtime}/nvim')
              if vim.fn.isdirectory(d) == 1 then return d end
              return '${default}'
            end)()
          '';

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
