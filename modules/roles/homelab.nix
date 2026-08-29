# Server on the home LAN: reachable over Tailscale, boots with systemd-boot.
{ config, ... }:
{
  flake.modules.nixos.roles-homelab = {
    imports = with config.flake.modules.nixos; [
      roles-server
      services-tailscale
      secrets-tailscale-key
      core-boot-systemd
    ];
  };
}
