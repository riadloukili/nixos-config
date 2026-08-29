# Docker (rootless by default) with compose.
# Also touches networking.firewall — keep in mind next to services/firewall.nix.
{
  flake.modules.nixos.services-docker =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.docker;
      daemonSettings = {
        iptables = true;
        ip-forward = true;
      }
      // lib.optionalAttrs (cfg.dns != [ ]) {
        inherit (cfg) dns;
        dns-opts = [ "ndots:0" ];
        dns-search = [ ];
      };
    in
    {
      options.my.docker = {
        enable = lib.mkEnableOption "Docker" // {
          default = true;
        };
        rootless = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Run the daemon as the user (rootless) instead of as root.";
        };
        privilegedPorts = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Allow rootless containers to bind ports below 1024.";
        };
        dns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "1.1.1.1"
            "1.0.0.1"
          ];
          description = "DNS servers for containers; empty list keeps Docker's default.";
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.docker = {
          enable = !cfg.rootless;
          daemon.settings = lib.mkIf (!cfg.rootless) daemonSettings;
          rootless = {
            enable = cfg.rootless;
            setSocketVariable = true;
            daemon.settings = daemonSettings;
          };
        };

        environment.systemPackages = [
          pkgs.docker-compose
        ]
        ++ lib.optional cfg.rootless pkgs.slirp4netns;

        security.wrappers.docker-rootlesskit = lib.mkIf (cfg.rootless && cfg.privilegedPorts) {
          owner = "root";
          group = "root";
          capabilities = "cap_net_bind_service+ep";
          source = "${pkgs.rootlesskit}/bin/rootlesskit";
        };

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        networking.firewall = {
          trustedInterfaces = [
            "docker0"
            "br-*"
          ];
          checkReversePath = lib.mkDefault "loose";
          allowedUDPPorts = lib.mkIf (cfg.dns != [ ]) [ 53 ];
        };
      };
    };
}
