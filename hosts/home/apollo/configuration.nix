
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/packages.nix
    ../../../modules/users
    ../../../modules/services/openssh.nix
    ../../../modules/services/firewall.nix
    ../../../modules/services/boot.nix
    ../../../modules/services/networking.nix
    ../../../profiles/server.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName   = builtins.baseNameOf ./.;
  time.timeZone         = "America/Toronto";
  i18n.defaultLocale    = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.variables.CLOUD_PROVIDER = builtins.baseNameOf (builtins.dirOf ./.); 

  mySystem.boot = {
    loader = "systemd-boot";
  };

  boot.initrd.luks.devices.luksCrypted.device = "/dev/nvme0n1p2";
  boot.initrd.luks.devices.luksCrypted.allowDiscards = true;

  users.users.riad.extraGroups  = [ "wheel" "docker" ];
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

  mySystem.packages = [
    pkgs.kitty.terminfo
  ];

  mySystem.networking.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  system.stateVersion = "25.05";
}
