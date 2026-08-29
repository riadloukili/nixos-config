# Fingerprint reader (enrol with `fprintd-enroll`). PAM services default to
# fingerprint auth once fprintd is enabled; greetd opts out (desktop/greetd.nix).
{
  flake.modules.nixos."hardware/fingerprint" = {
    services.fprintd.enable = true;
  };
}
