# eleuthia — personal laptop (ThinkPad Yoga, Intel).
{ mods, ... }:
{
  flake.modules.nixos.host-eleuthia = {
    imports = with mods.nixos; [
      profile-laptop
      user-riad
      boot-systemd-boot
      hardware-intel
      hardware-thinkpad
      hardware-fingerprint
      hardware-convertible
    ];

    system.stateVersion = "26.11";
    my.repo.localPath = "/home/riad/personal/nixos-config";
  };
}
