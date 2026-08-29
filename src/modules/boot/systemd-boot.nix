# systemd-boot on UEFI.
{
  flake.modules.nixos."boot/systemd-boot" =
    { lib, ... }:
    {
      boot.loader = {
        systemd-boot = {
          enable = true;
          editor = false;
          configurationLimit = 10;
        };
        efi.canTouchEfiVariables = true;
        timeout = lib.mkDefault 3;
      };
    };
}
