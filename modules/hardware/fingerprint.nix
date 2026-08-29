# Fingerprint reader (enrol with `fprintd-enroll`); PAM defaults to fingerprint auth once enabled.
{
  flake.modules.nixos.hardware-fingerprint = {
    services.fprintd.enable = true;
    security.pam.services.hyprlock.fprintAuth = true;
  };
}
