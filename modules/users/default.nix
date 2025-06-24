{ config, lib, pkgs, ... }:

let
  entries   = builtins.readDir ./.;
  paths     = lib.attrValues entries;
  nixFiles  = lib.filter (path:
    builtins.match ".*\\.nix$" (builtins.basename path) != null
  ) paths;
  userFiles = lib.filter (path:
    builtins.basename path != "default.nix"
  ) nixFiles;
in

lib.foldl' (acc: thePath:
  acc // import thePath
) {} userFiles
