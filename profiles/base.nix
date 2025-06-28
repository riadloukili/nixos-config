{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/services/garbage-collection.nix
  ];

  mySystem.packages = [
    pkgs.git
    pkgs.vim
    pkgs.htop
    pkgs.tmux
  ];
}
