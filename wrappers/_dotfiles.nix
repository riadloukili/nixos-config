# Shared constants for wrappers/*.nix (the `_` prefix keeps import-tree from loading it).
# Where wrappers look for the dotfiles checkout at runtime; each wrapper falls
# back to wrappers/defaults or home/defaults when the file is missing.
{
  runtime = "$HOME/personal/dotfiles";
}
