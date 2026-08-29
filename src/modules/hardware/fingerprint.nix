# Fingerprint reader (enrol with `fprintd-enroll`). PAM services default to
# fingerprint auth once fprintd is enabled; the login screen opts out (desktop/sddm.nix).
{
  flake.modules.nixos."hardware/fingerprint" = {
    services.fprintd.enable = true;
  };
}
