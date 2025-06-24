{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
    ../modules/services/docker.nix
  ];

  mySystem.docker = {
    enable = true;
    rootless = true;
    composePackage = true;
  };
}