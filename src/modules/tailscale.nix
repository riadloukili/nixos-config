# Tailscale (auth key comes from secrets.nix when enrolled).
{
  flake.modules.nixos."tailscale" =
    { lib, ... }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
      };
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
