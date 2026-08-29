# The programs a Wayland desktop needs to function (bar, launcher,
# notifications, lock/idle, terminal, screenshots, clipboard, controls, files,
# browser). Their configs come from each user's dotfiles.
{
  flake.modules.nixos."desktop/tools" =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        waybar
        swaynotificationcenter
        rofi
        wlogout
        hyprlock
        hypridle
        hyprpaper
        kitty
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
        brave
        mpv
        imv
        zathura
        xdg-utils
      ];
      security.pam.services.hyprlock = { };
    };
}
