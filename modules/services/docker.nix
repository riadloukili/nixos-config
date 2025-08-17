{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.docker = {
      enable = lib.mkEnableOption "Docker containerization";

      rootless = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable rootless Docker mode";
      };

      composePackage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Include docker-compose package";
      };

      enablePrivilegedPorts = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow rootless Docker to bind to privileged ports (< 1024)";
      };

      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "1.0.0.1" ];
        description = "DNS servers for Docker containers";
        example = [ "8.8.8.8" "8.8.4.4" ];
      };

      customDns = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable custom DNS configuration for Docker";
      };
    };
  };

  config = lib.mkIf config.mySystem.docker.enable {
    virtualisation.docker = if config.mySystem.docker.rootless then {
      enable = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = lib.mkIf config.mySystem.docker.customDns {
          dns = config.mySystem.docker.dns;
          "dns-opts" = [ "ndots:0" ];
          "dns-search" = [];
        };
      };
    } else {
      enable = true;
      daemon.settings = lib.mkIf config.mySystem.docker.customDns {
        dns = config.mySystem.docker.dns;
        "dns-opts" = [ "ndots:0" ];
        "dns-search" = [];
      };
    };

    environment.systemPackages = lib.optionals config.mySystem.docker.composePackage [
      pkgs.docker-compose
    ];

    security.wrappers = lib.mkIf (config.mySystem.docker.rootless && config.mySystem.docker.enablePrivilegedPorts) {
      docker-rootlesskit = {
        owner = "root";
        group = "root";
        capabilities = "cap_net_bind_service+ep";
        source = "${pkgs.rootlesskit}/bin/rootlesskit";
      };
    };
  };
}
