# Where wrappers look for the dotfiles checkout at *runtime*. Each wrapper
# falls back to a default shipped in modules/wrappers/defaults when the
# checkout lacks the file, so no dotfiles repo is required.
#
# To also bundle a dotfiles repo for `nix run` on machines without a
# checkout, add it as `inputs.dotfiles` (flake = false) and set
# `flake.dotfiles.store = inputs.dotfiles`.
{ lib, ... }:
{
  options.flake.dotfiles = {
    runtime = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/personal/dotfiles";
      description = "Shell expression for the dotfiles checkout, expanded when the program starts.";
    };
    store = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Store copy of the dotfiles (a flake input); null = runtime checkout only.";
    };
  };
}
