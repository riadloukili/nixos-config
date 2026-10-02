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

    # Autologin, because the disk is LUKS: reaching a greeter at all means the
    # passphrase has already been entered at boot, and asking a second time
    # proves nothing. Host-local rather than in users/riad, which other hosts
    # import — a server wants the greeter.
    #
    # SDDM's Relogin is left at its default of false, and that default is
    # exactly the split wanted here: log in automatically when the display
    # manager starts, show the greeter again after an explicit logout.
    services.displayManager.autoLogin = {
      enable = true;
      user = "riad";
    };

    system.stateVersion = "26.11";
    my.repo.localPath = "/home/riad/personal/nixos-config";
  };
}
