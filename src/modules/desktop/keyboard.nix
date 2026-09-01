# US QWERTY + Canadian Multilingual, Alt+Shift to toggle. Hyprland reads its
# own input settings from the dotfiles hypr config; keep the two in sync.
{
  flake.modules.nixos."desktop/keyboard" = {
    services.xserver.xkb = {
      layout = "us,ca";
      variant = ",multix";
      options = "grp:alt_shift_toggle";
    };
    console.useXkbConfig = true;
  };
}
