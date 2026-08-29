# tmux: settings come from `<dotfiles>/tmux/tmux.conf` (usable with TPM on
# non-Nix machines); Nix adds the plugins so nothing is downloaded at runtime.
{ config, ... }:
let
  dot = config.flake.dotfiles;
  conf = if dot.store != null then "${dot.store}/tmux/tmux.conf" else "${dot.runtime}/tmux/tmux.conf";
in
{
  flake.wrappers.tmux =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.tmux ];

      prefix = "C-s";
      sourceSensible = true;

      # Dotfiles first so plugin options (@minimal-tmux-*) are set before the
      # plugins run; `-q` keeps tmux usable when the checkout is missing.
      configBefore = ''
        source-file -q "${conf}"
      '';

      plugins = [
        (pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "minimal-tmux-status";
          version = "unstable-2026-07-08";
          src = pkgs.fetchFromGitHub {
            owner = "niksingh710";
            repo = "minimal-tmux-status";
            rev = "fa0d24c9454b831b5f482aae01464d4ccd0292dc";
            hash = "sha256-O5pESDP8kG9XWb6j1/nXhZvFJnXkH22mSl+Ubtuo2l8=";
          };
        })
      ];
    };
}
