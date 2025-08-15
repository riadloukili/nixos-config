{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.boot = {
      loader = lib.mkOption {
        type = lib.types.enum [ "grub" "systemd-boot" ];
        default = "grub";
        description = "Boot loader to use";
      };
      
      device = lib.mkOption {
        type = lib.types.str;
        default = "/dev/sda";
        description = "Boot device for GRUB (ignored for systemd-boot)";
      };
    };
  };

  config = {
    boot = {
      loader = if config.mySystem.boot.loader == "grub" then {
        grub = {
          enable = true;
          device = config.mySystem.boot.device;
        };
      } else {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
  };
}
