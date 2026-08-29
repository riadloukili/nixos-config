# Hot-editable dotfiles from a separate checkout (github:riadloukili/dotfiles).
#
# Each entry `foo` links ~/.config/foo -> <path>/foo. With `mutable = true`
# the link points at the live checkout (edit, no rebuild); with `mutable =
# false` the directory is copied into the store from `source` instead.
{
  flake.modules.homeManager.home-dotfiles =
    { config, lib, ... }:
    let
      cfg = config.my.dotfiles;
    in
    {
      options.my.dotfiles = {
        path = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/personal/dotfiles";
          description = "Absolute path of the dotfiles checkout on the machine.";
        };
        mutable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Symlink into the live checkout instead of copying into the store.";
        };
        source = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Store path of the dotfiles (only used when mutable = false).";
        };
        entries = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [
            "hypr"
            "waybar"
          ];
          description = "Directories under ~/.config to take from the dotfiles.";
        };
      };

      config = lib.mkIf (cfg.entries != [ ]) {
        assertions = [
          {
            assertion = cfg.mutable || cfg.source != null;
            message = "my.dotfiles.source must be set when my.dotfiles.mutable = false";
          }
        ];

        xdg.configFile = lib.genAttrs cfg.entries (
          entry:
          if cfg.mutable then
            {
              source = config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${entry}";
              force = true;
            }
          else
            {
              source = "${cfg.source}/${entry}";
              recursive = true;
            }
        );

        home.activation.checkDotfiles = lib.mkIf cfg.mutable (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -d "${cfg.path}" ]; then
              echo "warning: dotfiles checkout missing at ${cfg.path}; run:" >&2
              echo "  git clone https://github.com/riadloukili/dotfiles ${cfg.path}" >&2
            fi
          ''
        );
      };
    };
}
