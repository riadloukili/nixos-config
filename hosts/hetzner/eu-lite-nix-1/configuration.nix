{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/packages.nix
    ../../../modules/users
    ../../../modules/services/openssh.nix
    ../../../modules/services/firewall.nix
    ../../../modules/services/boot.nix
    ../../../profiles/base.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName   = "eu-lite-nix-1";
  time.timeZone         = "America/Toronto";
  i18n.defaultLocale    = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.variables.CLOUD_PROVIDER = builtins.baseNameOf (builtins.dirOf (builtins.dirOf ./.));

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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "25.05";
}
