# systemd-boot on UEFI.
{
  flake.modules.nixos.core-boot-systemd =
    { lib, ... }:
    {
      boot.loader = {
        systemd-boot = {
          enable = true;
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        timeout = lib.mkDefault 3;
      };
    };
}
