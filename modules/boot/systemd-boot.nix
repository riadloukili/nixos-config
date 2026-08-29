{
  flake.modules.nixos.boot-systemd-boot =
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
