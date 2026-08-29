# Headless machine (homelab or cloud): runs containers, updates itself from main.
{ mods, ... }:
{
  flake.modules.nixos.profile-server = {
    imports = with mods.nixos; [
      profile-base
      docker
      firewall
      auto-update
      tailscale
    ];
    networking.nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };
}
