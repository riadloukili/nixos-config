# US QWERTY + Canadian Multilingual, Alt+Shift to toggle. Hyprland reads its
# own input settings from the dotfiles (kept in sync in home/defaults/hypr).
{
  services.xserver.xkb = {
    layout = "us,ca";
    variant = ",multix";
    options = "grp:alt_shift_toggle";
  };
  console.useXkbConfig = true;
}
