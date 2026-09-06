# eleuthia — personal laptop (ThinkPad X13 Yoga Gen 4, Intel).
{ mods, ... }:
{
  flake.modules.nixos."hosts/eleuthia/default" = {
    imports = with mods.nixos; [
      profiles.laptop
      users.riad
      boot.systemd-boot
      hardware.thinkpad-x13-yoga
      desktop.autorotate # rotate the screen when folded into a tablet
    ];

    system.stateVersion = "26.11";
    my.repo.localPath = "/home/riad/personal/nixos-config";
  };
}
