{ config, lib, pkgs, ... }:

let
  dir = toString (./);
  allFiles = builtins.attrNames (builtins.readDir dir);
  userFiles = lib.filter
    (f: f != "default.nix" && lib.strings.hasSuffix ".nix" f)
    allFiles;
in
  lib.foldl' (acc: file:
    acc // import (dir + "/" + file)
  ) {} userFiles
