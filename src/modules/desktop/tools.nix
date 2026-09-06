# The programs a Wayland desktop needs around the shell (polkit, terminal,
# screenshots, clipboard, pickers, controls, files, monitors, theming). The
# shell itself (bar, launcher, notifications, lock, idle, OSD, wallpaper) is
# caelestia, set up per user (users/riad/home.nix).
{
  flake.modules.nixos."desktop/tools" =
    { pkgs, ... }:
    {
      programs.thunar.enable = true; # the package and its dbus service

      # Thunar lists removable drives through gvfs-udisks2-volume-monitor; the
      # thunar module does not pull gvfs in, so without this the sidebar shows
      # no devices and there is nothing to click to mount or eject. Mounting
      # them on plug is riad's udiskie (users/riad/home.nix).
      services.gvfs.enable = true;

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
        hyprpicker # colour picker (SUPER+SHIFT+C)
        brightnessctl
        playerctl
        pavucontrol
        nwg-displays
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
        # theming caelestia drives: adw-gtk3 + Papirus for GTK, qtengine + Darkly for Qt
        adw-gtk3
        papirus-icon-theme
        papirus-folders
        qtengine
        darkly
      ];
    };
}
