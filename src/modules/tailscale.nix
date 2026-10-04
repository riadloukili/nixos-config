# Tailscale client; joins with `tailscale-auth-key` from secrets/hosts/common.yaml
# once that key is enrolled (nothing is declared until then).
{ mods, ... }:
{
  flake.modules.nixos."tailscale" =
    { config, lib, ... }:
    let
      secrets = config.my.secrets.key "hosts/common.yaml" "tailscale-auth-key";
    in
    {
      imports = [ mods.nixos.secrets ];

      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
        authKeyFile = lib.mkIf (secrets != null) config.sops.secrets.tailscale-auth-key.path;
      };
      sops.secrets.tailscale-auth-key = lib.mkIf (secrets != null) { sopsFile = secrets; };
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
