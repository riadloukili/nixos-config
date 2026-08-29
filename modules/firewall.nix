# Firewall with explicit port lists. docker.nix, ssh.nix and tailscale.nix add their own rules.
{
  flake.modules.nixos.firewall =
    { config, lib, ... }:
    let
      cfg = config.my.firewall;
      range = lib.types.submodule {
        options = {
          from = lib.mkOption { type = lib.types.port; };
          to = lib.mkOption { type = lib.types.port; };
        };
      };
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
      };
      ranges = lib.mkOption {
        type = lib.types.listOf range;
        default = [ ];
      };
    in
    {
      options.my.firewall = {
        enable = lib.mkEnableOption "the firewall" // {
          default = true;
        };
        tcp = ports;
        udp = ports;
        tcpRanges = ranges;
        udpRanges = ranges;
      };

      config.networking.firewall = {
        inherit (cfg) enable;
        allowedTCPPorts = cfg.tcp;
        allowedUDPPorts = cfg.udp;
        allowedTCPPortRanges = cfg.tcpRanges;
        allowedUDPPortRanges = cfg.udpRanges;
      };
    };
}
