# Live-ISO common: turns any host/role configuration into a bootable image.
# Login: riad / nixos (SSH keys also work). The repo is at /etc/nixos-config.
{ inputs, ... }:
{
  flake.modules.nixos.installer-base =
    {
      config,
      options,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

      options.my.installer.isoName = lib.mkOption {
        type = lib.types.str;
        description = "Base name of the produced image.";
      };

      config = lib.mkMerge [
        # Only hosts with the server role have auto-update; disable it where present.
        (lib.optionalAttrs (options.my ? autoUpdate) { my.autoUpdate.enable = lib.mkForce false; })
        {
          image.fileName = lib.mkForce "${config.my.installer.isoName}.iso";
          isoImage = {
            makeEfiBootable = true;
            makeUsbBootable = true;
            squashfsCompression = "zstd -Xcompression-level 6";
          };

          networking.hostName = lib.mkForce "${config.my.installer.isoName}-live";

          # A live system has no secrets and installs no bootloader.
          my.secrets.enable = lib.mkForce false;
          my.gc.enable = lib.mkForce false;
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.loader.grub.enable = lib.mkForce false;
          services.openssh.settings.PasswordAuthentication = lib.mkForce false;

          users.users.riad.password = "nixos";
          users.users.riad.hashedPasswordFile = lib.mkForce null;
          # The stock installer user is not needed.
          users.users.nixos.enable = lib.mkForce false;

          environment.etc."nixos-config".source = inputs.self;
          environment.systemPackages = [
            inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko
            pkgs.git
            pkgs.just
            pkgs.parted
            pkgs.cryptsetup
          ];

          # Faster boots and smaller images.
          documentation.enable = lib.mkForce false;
          system.installer.channel.enable = false;
        }
      ];
    };
}
