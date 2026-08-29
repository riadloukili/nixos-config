# Fingerprint reader (enrol with `fprintd-enroll`); PAM defaults to fingerprint auth once enabled.
{
  services.fprintd.enable = true;
  security.pam.services.hyprlock.fprintAuth = true;
}
