# Neovim + tools for a LazyVim config. Config dir: <dotfiles>/nvim if present,
# else the LazyVim starter in home/defaults/nvim.
{
  flake.wrappers.nvim =
    {
      wlib,
      pkgs,
      lib,
      ...
    }:
    let
      dot = import ./_dotfiles.nix;
      default = ../home/defaults/nvim;
    in
    {
      imports = [ wlib.wrapperModules.neovim ];

      settings.config_directory = lib.generators.mkLuaInline ''
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
