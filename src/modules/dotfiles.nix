# Dotfiles: whatever the checkout at my.dotfiles.path contains is linked into
# ~/.config (each top-level directory → ~/.config/<name>), at activation.
# Missing checkout or missing entry → the program uses its own built-in
# defaults; nothing is shipped from this repo. Links are live, so editing the
# checkout needs no rebuild.
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
    in
    {
      options.my.dotfiles = {
        enable = lib.mkEnableOption "linking the dotfiles checkout into ~/.config" // {
          default = true;
        };
        path = lib.mkOption {
          type = lib.types.str;
          default = "${config.home.homeDirectory}/personal/dotfiles";
          description = "Dotfiles checkout (git clone of github:riadloukili/dotfiles).";
        };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            ".git"
            ".github"
          ];
          description = "Top-level directories of the checkout not to link.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ -d "${cfg.path}" ]; then
            for src in "${cfg.path}"/*/ "${cfg.path}"/.*/; do
              [ -d "$src" ] || continue
              name=$(${pkgs.coreutils}/bin/basename "$src")
              case " ${toString cfg.exclude} . .. " in *" $name "*) continue ;; esac
              dest="${config.xdg.configHome}/$name"
              if [ -e "$dest" ] && [ ! -L "$dest" ]; then
                echo "dotfiles: moving existing $dest to $dest.bak" >&2
                run mv "$dest" "$dest.bak"
              fi
              run mkdir -p "${config.xdg.configHome}"
              run ${pkgs.coreutils}/bin/ln -sfnT "''${src%/}" "$dest"
            done
          else
            echo "dotfiles: no checkout at ${cfg.path}; programs use their own defaults" >&2
          fi
        '';
      };
    };
}
