# ~/.config/<name> directories with layered sources, resolved at activation:
#   1. <my.dotfiles.path>/<name> if the dotfiles checkout has it (hot-editable);
#   2. otherwise the default shipped here (my.dotfiles.entries.<name>.default,
#      e.g. home/defaults/hypr), declared by the module installing the program.
# Any dotfiles repo works, including none, or one that overrides a few entries.
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
      link = name: entry: ''
        link "${name}" "${cfg.path}/${name}" "${entry.default}"
      '';
    in
    {
      options.my.dotfiles = {
        path = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/personal/dotfiles";
          description = "Dotfiles checkout; entries found there override the defaults.";
        };
        entries = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options.default = lib.mkOption {
                type = lib.types.path;
                description = "Directory used when the dotfiles do not provide this entry.";
              };
            }
          );
          default = { };
        };
      };

      config = lib.mkIf (cfg.entries != { }) {
        home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          link() {
            local name="$1" override="$2" default="$3" target
            local dest="${config.xdg.configHome}/$name"
            if [ -e "$override" ]; then target="$override"; else target="$default"; fi
            if [ -e "$dest" ] && [ ! -L "$dest" ]; then
              echo "dotfiles: moving existing $dest to $dest.bak" >&2
              run mv "$dest" "$dest.bak"
            fi
            run mkdir -p "$(dirname "$dest")"
            run ${pkgs.coreutils}/bin/ln -sfnT "$target" "$dest"
          }
          ${lib.concatStrings (lib.mapAttrsToList link cfg.entries)}
          [ -d "${cfg.path}" ] || echo "dotfiles: no checkout at ${cfg.path}; using defaults" >&2
        '';
      };
    };
}
