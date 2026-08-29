# Passwordless sudo for wheel (needed by deploy-rs and unattended tooling).
{
  flake.modules.nixos.core-sudo = {
    security.sudo.wheelNeedsPassword = false;
  };
}
