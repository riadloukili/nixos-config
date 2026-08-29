# Compositor-agnostic Wayland desktop stack. Configs for these come from the
# dotfiles checkout; this only installs the programs.
{
  flake.modules.homeManager.home-wayland-common =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        waybar
        swaynotificationcenter
        rofi
        wlogout
        hyprlock
        hypridle
        hyprpaper
        awww
        wallust
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
        thunar
        xarchiver
        qalculate-gtk
      ];

      my.dotfiles.entries = [
        "waybar"
        "rofi"
        "swaync"
        "wlogout"
        "wallust"
      ];

      services.cliphist.enable = true;
    };
}
