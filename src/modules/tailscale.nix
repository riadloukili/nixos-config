# Tailscale client; joins with `tailscale-auth-key` from secrets/common.yaml once enrolled.
{ mods, ... }:
{
  flake.modules.nixos."tailscale" =
    { config, lib, ... }:
    {
      imports = [ mods.nixos.secrets ];

      services.tailscale = {
        enable = true;
        useRoutingFeatures = lib.mkDefault "client";
        authKeyFile = lib.mkIf config.my.secrets.enable config.sops.secrets.tailscale-auth-key.path;
      };
      sops.secrets.tailscale-auth-key = lib.mkIf config.my.secrets.enable {
        sopsFile = config.my.secrets.commonFile;
      };
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
}
