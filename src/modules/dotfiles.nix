# Dotfiles: whatever the checkout at my.dotfiles.path contains is linked in,
# at activation:
#   <checkout>/<name>/      → ~/.config/<name>   (program configs)
#   <checkout>/home/<name>  → ~/<name>           (anything living outside ~/.config,
#                                                 e.g. home/.themes, home/.local/share/fonts)
# ~/bin is on PATH, so home/bin is where the checkout's own scripts go (shikane
# profiles call wks-range by name, for one).
# Missing checkout or missing entry → the program uses its own built-in
# defaults; nothing is shipped from this repo. Links are live, so editing the
# checkout needs no rebuild. The directory list is only known at activation
# (the checkout is not in the store), hence a script rather than xdg.configFile.
{
  flake.modules.homeManager.dotfiles =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.dotfiles;
      link = pkgs.writeShellApplication {
        name = "link-dotfiles";
        text = ''
          checkout=$1 configHome=$2 home=$3
          if [ ! -d "$checkout" ]; then
            echo "dotfiles: no checkout at $checkout; programs use their own defaults" >&2
            exit 0
          fi
          link() { # link SRC DEST: replace DEST with a symlink to SRC, backing up a real file/dir
            local src=$1 dest=$2
            if [ -e "$dest" ] && [ ! -L "$dest" ]; then
              local backup
              backup="$dest.hm-backup.$(date +%s)"
              echo "dotfiles: moving existing $dest to $backup" >&2
              mv -T "$dest" "$backup"
            fi
            mkdir -p "$(dirname "$dest")"
            ln -sfnT "$src" "$dest"
          }
          for src in "$checkout"/*/; do
            src=''${src%/}; name=''${src##*/}
            [ "$name" = home ] && continue
            link "$src" "$configHome/$name"
          done
          shopt -s dotglob nullglob
          for src in "$checkout"/home/*; do
            name=''${src##*/}
            link "$src" "$home/$name"
          done
        '';
      };
    in
    {
      options.my.dotfiles.path = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/personal/dotfiles";
        description = "Dotfiles checkout (git clone of github:riadloukili/dotfiles).";
      };

      config = {
        home.sessionPath = [ "${config.home.homeDirectory}/bin" ];

        assertions = [
          {
            assertion = lib.hasPrefix "/" cfg.path;
            message = "my.dotfiles.path must be absolute, got ${cfg.path}";
          }
        ];
        home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe link} ${lib.escapeShellArg cfg.path} ${lib.escapeShellArg config.xdg.configHome} ${lib.escapeShellArg config.home.homeDirectory}
        '';
      };
    };
}
