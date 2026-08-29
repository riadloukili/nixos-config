# eleuthia — personal laptop (ThinkPad Yoga, Intel).
{ mods, ... }:
{
  flake.modules.nixos."hosts/eleuthia/default" = {
    imports = with mods.nixos; [
      profiles.laptop
      users.riad
      boot.systemd-boot
      hardware.intel
      hardware.thinkpad
      hardware.fingerprint
      hardware.convertible
    ];

    system.stateVersion = "26.11";
    my.repo.localPath = "/home/riad/personal/nixos-config";
  };
}
