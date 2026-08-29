# Where wrappers find the hot-editable dotfiles checkout at *runtime*.
#
# The dotfiles repo (github:riadloukili/dotfiles) is the single source of
# truth for nvim, tmux and zsh config so the same files work on non-Nix
# machines. Wrappers only add the binary, plugins and tools around it.
#
# Once the repo is published, add it as `inputs.dotfiles` (flake = false) and
# set `flake.dotfiles.store = inputs.dotfiles` so `nix run` variants also
# work on machines without a checkout.
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
