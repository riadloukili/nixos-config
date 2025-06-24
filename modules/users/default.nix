{ config, lib, pkgs, ... }:

let
  thisDir   = ./.
  allFiles   = builtins.attrNames (builtins.readDir thisDir);
  userFiles  = lib.filter (f: f != "default.nix" && lib.strings.hasSuffix ".nix" f) allFiles;
in
  lib.foldl' (acc: name:
    let
      modulePath = toString thisDir + "/" + name;
    in
      acc // import modulePath
  ) {} userFiles
