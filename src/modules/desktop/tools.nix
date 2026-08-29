# The programs a Wayland desktop needs to function (bar, launcher,
# notifications, lock/idle, terminal, screenshots, clipboard, controls, files,
# browser). Their configs come from each user's dotfiles.
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
        rofi
        wlogout
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
        xarchiver
        qalculate-gtk
        brave
        mpv
        imv
        zathura
        xdg-utils
      ];
    };
}
