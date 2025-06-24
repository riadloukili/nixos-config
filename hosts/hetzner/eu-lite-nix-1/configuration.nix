{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName   = "eu-lite-nix-1";
  time.timeZone         = "America/Toronto";
  i18n.defaultLocale    = "en_US.UTF-8";

  users.users.riad.extraGroups  = [ "wheel" ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable               = true;
  services.openssh.passwordAuthentication = false;

  networking.firewall.enable           = true;
  networking.firewall.allowedTCPPorts  = [ 22 ];

  mySystem.packages = [];

  system.stateVersion = "25.05";
}
