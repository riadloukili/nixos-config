# Turns a host/profile configuration into a live ISO. Login: riad / nixos
# (SSH keys work too). The repo is available at /etc/nixos-config.
{
  config,
  options,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  options.my.installer.name = lib.mkOption { type = lib.types.str; };

  config = lib.mkMerge [
    (lib.optionalAttrs (options.my ? autoUpdate) { my.autoUpdate.enable = lib.mkForce false; })
    {
      image.fileName = lib.mkForce "nixos-${config.my.installer.name}.iso";
      isoImage = {
        makeEfiBootable = true;
        makeUsbBootable = true;
        squashfsCompression = "zstd -Xcompression-level 6";
      };

      networking.hostName = lib.mkForce "${config.my.installer.name}-live";

      # A live system has no secrets, no gc timer and installs no bootloader.
      my.secrets.enable = lib.mkForce false;
      my.gc.enable = lib.mkForce false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce false;

      users.users = {
        riad.password = "nixos";
        riad.hashedPasswordFile = lib.mkForce null;
        nixos.enable = lib.mkForce false;
      };

      environment.etc."nixos-config".source = inputs.self;
      environment.systemPackages = [
        inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
        pkgs.git
        pkgs.parted
        pkgs.cryptsetup
      ];

      documentation.enable = lib.mkForce false;
      system.installer.channel.enable = false;
    }
  ];
}
