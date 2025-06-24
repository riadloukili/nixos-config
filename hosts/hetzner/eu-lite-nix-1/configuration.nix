{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName   = "eu-lite-nix-1";
  time.timeZone         = "America/Toronto";
  i18n.defaultLocale    = "en_US.UTF-8";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

  users.users.riad.extraGroups  = [ "wheel" ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable               = true;
  services.openssh.PasswordAuthentication = false;

  networking.firewall.enable           = true;
  networking.firewall.allowedTCPPorts  = [ 22 ];

  mySystem.packages = [];

  system.stateVersion = "25.05";
}
