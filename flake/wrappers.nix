# Programs bundled with their config (nix-wrapper-modules). Every file in
# ../wrappers/*.nix becomes flake.wrappers.<name> and packages.<system>.<name>,
# so `nix run github:riadloukili/nixos-config#nvim` works anywhere.
{ inputs, lib, ... }:
let
  dir = ../wrappers;
  files = lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".nix" n && n != "dotfiles.nix") (
    builtins.readDir dir
  );
in
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];

  flake.wrappers = lib.mapAttrs' (
    file: _: lib.nameValuePair (lib.removeSuffix ".nix" file) (dir + "/${file}")
  ) files;
}
