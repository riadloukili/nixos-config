# Flatpak, for apps with no usable Nix package. Fusion 360 is one: no native
# Linux build, nothing in nixpkgs — it runs under Wine, and Bottles
# (`flatpak install flathub com.usebottles.bottles`) ships a Fusion installer
# recipe. Portals are the other half of that (file chooser, screen share);
# the desktop profile pulls them in via desktop/hyprland.
{
  flake.modules.nixos."desktop/flatpak" =
    { pkgs, ... }:
    {
      services.flatpak.enable = true;
      xdg.portal.enable = true; # asserted by the flatpak module

      # Nothing declares remotes for us, so add Flathub once per boot
      # (--if-not-exists makes it a no-op afterwards).
      systemd.services.flatpak-flathub = {
        description = "Register the Flathub flatpak remote";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists \
            flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        '';
      };
    };
}
