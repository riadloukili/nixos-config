{ config, lib, pkgs, ... }:

let
  dir       = ./.;
  entries   = builtins.readDir dir;
  userFiles = lib.filter
    (f: f != "default.nix" && lib.strings.hasSuffix ".nix" f)
    (builtins.attrNames entries);
in

lib.foldl' (acc: name:
  acc // import (dir + "/${name}")
) {} userFiles
