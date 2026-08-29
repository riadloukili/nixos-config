# tmux: <dotfiles>/tmux/tmux.conf if present, else wrappers/defaults/tmux.conf;
# plugins come from Nix so nothing is downloaded at runtime.
{
  flake.wrappers.tmux =
    { wlib, pkgs, ... }:
    let
      dot = import ./_dotfiles.nix;
    in
    {
      imports = [ wlib.wrapperModules.tmux ];

      prefix = "C-s";
      sourceSensible = true;

      # Config first so plugin options (@minimal-tmux-*) are set before the plugins run.
      configBefore = ''
        if-shell 'test -f "${dot.runtime}/tmux/tmux.conf"' \
          'source-file "${dot.runtime}/tmux/tmux.conf"' \
          'source-file "${./defaults/tmux.conf}"'
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
