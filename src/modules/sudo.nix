# Passwordless sudo for wheel: rebuilds and `just push` run unattended.
{
  flake.modules.nixos."sudo" = {
    security.sudo.wheelNeedsPassword = false;
  };
}
