# Tailscale (auth key comes from modules/secrets.nix when enrolled).
{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
