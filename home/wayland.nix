# Compositor-agnostic Wayland stack. Configs are dotfiles entries
# (home/dotfiles.nix): checkout override, else home/defaults/<name>.
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

  my.dotfiles.entries = {
    waybar.default = ./defaults/waybar;
    rofi.default = ./defaults/rofi;
    swaync.default = ./defaults/swaync;
    wlogout.default = ./defaults/wlogout;
  };

  services.cliphist.enable = true;
}
