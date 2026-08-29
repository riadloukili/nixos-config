# Fingerprint reader: enrol with `fprintd-enroll`. PAM services default to
# fingerprint auth once fprintd is enabled (login, sudo, hyprlock).
{
  flake.modules.nixos.hardware-fingerprint = {
    services.fprintd.enable = true;
    security.pam.services.hyprlock.fprintAuth = true;
  };
}
