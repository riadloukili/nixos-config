# Firewall with explicit port and range lists.
# services/docker.nix and core/ssh.nix also add rules; check them too.
{
  flake.modules.nixos.services-firewall =
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
        example = [
          {
            from = 20000;
            to = 20100;
          }
        ];
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
