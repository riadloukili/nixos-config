# Tailscale client; joins with `tailscale-auth-key` from secrets/hosts/common.yaml once it exists.
{ mods, ... }:
{
  flake.modules.nixos."tailscale" =
    { config, lib, ... }:
    let
      secrets = config.my.secrets.file "hosts/common.yaml";
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
