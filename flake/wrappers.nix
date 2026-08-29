# Programs bundled with their config (nix-wrapper-modules). Each wrappers/<name>.nix
# registers flake.wrappers.<name>; the flake module also exports every one as
# packages.<system>.<name>, so `nix run github:riadloukili/nixos-config#nvim` works anywhere.
{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];
}
