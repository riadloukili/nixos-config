# tmux: settings from the dotfiles checkout's `tmux/tmux.conf` when present,
# otherwise modules/wrappers/defaults/tmux.conf (TPM-compatible for non-Nix
# machines). Nix adds the plugins so nothing is downloaded at runtime.
{ config, ... }:
let
  dot = config.flake.dotfiles;
  default = ./defaults/tmux.conf;
in
{
  flake.wrappers.tmux =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.tmux ];

      prefix = "C-s";
      sourceSensible = true;

      # Config first so plugin options (@minimal-tmux-*) are set before the plugins run.
      configBefore =
        if dot.store != null then
          ''source-file "${
            if builtins.pathExists "${dot.store}/tmux/tmux.conf" then "${dot.store}/tmux/tmux.conf" else default
          }"''
        else
          ''
            if-shell 'test -f "${dot.runtime}/tmux/tmux.conf"' \
              'source-file "${dot.runtime}/tmux/tmux.conf"' \
              'source-file "${default}"'
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
