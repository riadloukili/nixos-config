# The programs a Wayland desktop needs to function (bar, launcher,
# notifications, lock/idle, polkit, terminal, screenshots, clipboard, controls,
# wallpaper/theming, files, monitors). Their configs come from each user's dotfiles.
{
  flake.modules.nixos."desktop/tools" =
    { config, pkgs, ... }:
    {
      programs = {
        # Package + PAM service; also runs hypridle as a user service (so no exec-once for it).
        hyprlock.enable = true;
        thunar.enable = true; # package + gvfs/tumbler wiring
      };
      security.pam.services.hyprlock.fprintAuth = config.services.fprintd.enable;

      environment.systemPackages = with pkgs; [
        waybar
        swaynotificationcenter
        libnotify # notify-send, used by the dots for every OSD
        rofi
        wlogout
        hyprpolkitagent
        kitty
        awww
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
        brightnessctl
        playerctl
        pamixer
        pavucontrol
        networkmanagerapplet
        nwg-displays
        nwg-look
        shikane
        wev
        yad
        loupe
        file-roller
        gnome-system-monitor
        xarchiver
        qalculate-gtk
        imv
        zathura
        xdg-utils
        (python3.withPackages (ps: [ ps.requests ])) # the dots' weather/scripts
        libsForQt5.qt5ct
        qt6Packages.qt6ct
        kdePackages.qtstyleplugin-kvantum
      ];
    };
}
