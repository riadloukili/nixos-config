# Docker, rootless by default, with compose.
{
  flake.modules.nixos."docker" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.docker;
      # Explicit resolvers: containers must not inherit a host-only resolver.
      daemonSettings = {
        dns = [
          "1.1.1.1"
          "1.0.0.1"
        ];
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
      };

      config = lib.mkIf cfg.enable {
        virtualisation.docker = {
          enable = !cfg.rootless;
          daemon.settings = daemonSettings;
          rootless = {
            enable = cfg.rootless;
            setSocketVariable = true;
            daemon.settings = daemonSettings;
          };
        };

        environment.systemPackages = [ pkgs.docker-compose ] ++ lib.optional cfg.rootless pkgs.slirp4netns;

        # Rootless containers may bind ports below 1024 (e.g. a reverse proxy).
        security.wrappers.docker-rootlesskit = lib.mkIf cfg.rootless {
          owner = "root";
          group = "root";
          capabilities = "cap_net_bind_service+ep";
          source = "${pkgs.rootlesskit}/bin/rootlesskit";
        };

        # Rootful docker manages bridges on the host; trust them so containers
        # can reach host services, and relax reverse-path filtering for NAT.
        networking.firewall = lib.mkIf (!cfg.rootless) {
          trustedInterfaces = [
            "docker0"
            "br+"
          ];
          checkReversePath = "loose";
        };
      };
    };
}
