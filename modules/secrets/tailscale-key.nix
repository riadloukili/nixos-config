# Tailscale pre-auth key (secrets/common.yaml: tailscale-auth-key), consumed
# by services/tailscale.nix when present.
{
  flake.modules.nixos.secrets-tailscale-key =
    { config, lib, ... }:
    lib.mkIf (config.my.secrets.enable && config.services.tailscale.enable) {
      sops.secrets.tailscale-auth-key.sopsFile = ../../secrets/common.yaml;
    };
}
