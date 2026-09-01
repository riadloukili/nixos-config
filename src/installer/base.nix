# Turns a host/profile configuration into a live ISO. Login: riad / nixos
# (SSH keys work too).
{ mods, ... }:
{
  flake.modules.nixos."installer/base" =
    {
      config,
      lib,
      pkgs,
      inputs,
      modulesPath,
      ...
    }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        mods.nixos.auto-update
      ];

      options.my.installer.name = lib.mkOption { type = lib.types.str; };

      config = {
        image.fileName = lib.mkForce "nixos-${config.my.installer.name}.iso";
        isoImage = {
          makeEfiBootable = true;
          makeUsbBootable = true;
          squashfsCompression = "zstd -Xcompression-level 6";
        };

        networking.hostName = lib.mkForce "${config.my.installer.name}-live";

        # A live system does not update itself, has no secrets, no cleaner
        # timer and installs no bootloader.
        my.autoUpdate.enable = lib.mkForce false;
        my.secrets.enable = lib.mkForce false;
        programs.nh.clean.enable = lib.mkForce false;
        boot.loader.systemd-boot.enable = lib.mkForce false;
        boot.loader.grub.enable = lib.mkForce false;

        users.users = {
          riad.password = "nixos";
          nixos.enable = lib.mkForce false;
        };

        environment.systemPackages = [
          inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
          pkgs.git
          pkgs.parted
          pkgs.cryptsetup
        ];

        system.installer.channel.enable = false;
      };
    };
}
