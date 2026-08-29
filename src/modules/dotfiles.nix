# Dotfiles: whatever the checkout at my.dotfiles.path contains is linked into
# ~/.config (each top-level directory → ~/.config/<name>), at activation.
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
          checkout=$1 configHome=$2
          if [ ! -d "$checkout" ]; then
            echo "dotfiles: no checkout at $checkout; programs use their own defaults" >&2
            exit 0
          fi
          mkdir -p "$configHome"
          for src in "$checkout"/*/; do
            name=''${src%/}; name=''${name##*/}
            dest="$configHome/$name"
            if [ -e "$dest" ] && [ ! -L "$dest" ]; then
              backup="$dest.hm-backup.$(date +%s)"
              echo "dotfiles: moving existing $dest to $backup" >&2
              mv -T "$dest" "$backup"
            fi
            ln -sfnT "''${src%/}" "$dest"
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
        assertions = [
          {
            assertion = lib.hasPrefix "/" cfg.path;
            message = "my.dotfiles.path must be absolute, got ${cfg.path}";
          }
        ];
        home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe link} ${lib.escapeShellArg cfg.path} ${lib.escapeShellArg config.xdg.configHome}
        '';
      };
    };
}
