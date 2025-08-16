{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
    ../modules/services/docker.nix
    ../modules/services/auto-update.nix
  ];

  mySystem.docker = {
    enable = true;
    rootless = true;
    composePackage = true;
    enablePrivilegedPorts = true;
  };
}
