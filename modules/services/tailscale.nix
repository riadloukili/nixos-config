# Tailscale, joined with an auth key from sops when available.
{
  flake.modules.nixos.services-tailscale =
    { config, lib, ... }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
        authKeyFile = lib.mkIf (
          config.sops.secrets ? tailscale-auth-key
        ) config.sops.secrets.tailscale-auth-key.path;
      };
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
