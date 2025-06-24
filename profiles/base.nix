{ config, pkgs, lib, … }:

{
  mySystem.packages = [
    pkgs.git
    pkgs.vim
    pkgs.htop
  ];
}
