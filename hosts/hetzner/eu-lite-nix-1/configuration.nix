{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName   = "eu-lite-nix-1";
  time.timeZone         = "America/Toronto";
  i18n.defaultLocale    = "en_US.UTF-8";

  mySystem.boot = {
    loader = "grub";
    device = "/dev/sda";
  };

  users.users.riad.extraGroups  = [ "wheel" ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  mySystem.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [ 22 ];
  };

  mySystem.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  mySystem.packages = [];

  system.stateVersion = "25.05";
}
