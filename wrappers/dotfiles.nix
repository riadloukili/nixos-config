# Not a wrapper: shared constants for wrappers/*.nix (skipped by flake/wrappers.nix).
# Where wrappers look for the dotfiles checkout at runtime; each wrapper falls
# back to wrappers/defaults or home/defaults when the file is missing.
{
  runtime = "$HOME/personal/dotfiles";
}
