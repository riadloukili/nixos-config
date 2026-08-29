# Headless machine (homelab or cloud): runs containers, updates itself from main.
{
  imports = [
    ./base.nix
    ../modules/docker.nix
    ../modules/firewall.nix
    ../modules/auto-update.nix
    ../modules/tailscale.nix
  ];

  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];
}
