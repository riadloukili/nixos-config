{ lib, … }:

let
  allFiles = builtins.attrNames (builtins.readDir .);
  userFiles = lib.filter (f: f != "default.nix" && lib.strings.hasSuffix ".nix" f) allFiles;
in
  lib.foldl' (acc: name: acc // import ./${name}) {} userFiles
