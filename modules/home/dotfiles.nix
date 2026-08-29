# Per-program config directories under ~/.config, with layered sources:
#
#   1. `<my.dotfiles.path>/<name>` in the dotfiles checkout, if that entry
#      exists (hot-editable, no rebuild) — or `<store>/<name>` when a store
#      copy (flake input) is configured;
#   2. otherwise the default shipped by the aspect that installs the program
#      (`my.dotfiles.entries.<name>.default`, e.g. modules/desktop/defaults/hypr).
#
# Resolution happens at activation, so any dotfiles repo works, including
# none at all or one that only overrides a few programs.
{
  flake.modules.homeManager.home-dotfiles =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.dotfiles;
      checkout = if cfg.store != null then toString cfg.store else cfg.path;
      link = name: entry: ''
        link "${name}" "${checkout}/${name}" "${entry.default}"
      '';
    in
    {
      options.my.dotfiles = {
        path = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/personal/dotfiles";
          description = "Dotfiles checkout on the machine; entries found here override the defaults.";
        };
        store = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Store copy of a dotfiles repo (flake input) to use instead of the checkout.";
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
          description = "~/.config/<name> directories managed this way, with their defaults.";
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
          if [ ! -d "${checkout}" ]; then
            echo "dotfiles: no checkout at ${checkout}; using defaults for all entries" >&2
          fi
        '';
      };
    };
}
