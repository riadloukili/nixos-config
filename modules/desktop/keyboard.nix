# Keyboard layouts for desktops: US QWERTY and Canadian Multilingual
# (`ca(multix)`), toggled with Alt+Shift. Compositors read the same XKB
# defaults from /etc/default/keyboard via services.xserver.xkb; Hyprland's
# `input { kb_layout, kb_variant, kb_options }` in the dotfiles should match.
{
  flake.modules.nixos.desktop-keyboard = {
    services.xserver.xkb = {
      layout = "us,ca";
      variant = ",multix";
      options = "grp:alt_shift_toggle";
    };
    console.useXkbConfig = true;
  };
}
