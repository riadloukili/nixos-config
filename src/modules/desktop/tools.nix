# The programs a Wayland desktop needs around the shell (polkit, terminal,
# screenshots, clipboard, pickers, controls, files, monitors, theming). The
# shell itself (bar, launcher, notifications, lock, idle, OSD, wallpaper) is
# caelestia, set up per user (users/riad/home.nix).
{
  flake.modules.nixos."desktop/tools" =
    { pkgs, ... }:
    {
      programs.thunar.enable = true; # package + gvfs/tumbler wiring

      environment.systemPackages = with pkgs; [
        libnotify # notify-send
        hyprpolkitagent
        kitty
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
        fuzzel # caelestia's clipboard/emoji picker
        brightnessctl
        playerctl
        pavucontrol
        networkmanagerapplet
        nwg-displays
        nwg-look
        shikane
        wev
        loupe
        file-roller
        gnome-system-monitor
        xarchiver
        qalculate-gtk
        imv
        zathura
        xdg-utils
        libsForQt5.qt5ct
        qt6Packages.qt6ct
        kdePackages.qtstyleplugin-kvantum
      ];
    };
}
