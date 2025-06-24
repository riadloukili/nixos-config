{ config, lib, pkgs, ... }:

let
  files = builtins.readDir ./modules/users;
  userNames = lib.filter
    (n: n != "default.nix" && lib.strings.hasSuffix ".nix" n)
    (builtins.attrNames files);
in
lib.foldl' (acc: name:
  acc // import files.${name}
) {} userNames
