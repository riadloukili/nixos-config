# SDDM (Wayland) as the login screen; lists every installed session.
{
  flake.modules.nixos."desktop/sddm" = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    # Password at the greeter; fingerprint is for hyprlock/sudo.
    security.pam.services.sddm.fprintAuth = false;
  };
}
