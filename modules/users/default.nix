{ config, lib, pkgs, … }:

let
  thisDir   = ./.;
  allFiles  = builtins.attrNames (builtins.readDir thisDir);
  userFiles = lib.filter
    (f: f != "default.nix" && lib.strings.hasSuffix ".nix" f)
    allFiles;
in
lib.foldl' (acc: name:
  acc // import (thisDir + "/" + name)
) {} userFiles
