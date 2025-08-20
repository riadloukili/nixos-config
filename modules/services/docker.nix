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
        daemon.settings = lib.mkMerge [
          (lib.mkIf config.mySystem.docker.customDns {
            dns = config.mySystem.docker.dns;
            "dns-opts" = [ "ndots:0" ];
            "dns-search" = [];
          })
          {
            "iptables" = true;
            "ip-forward" = true;
          }
        ];
      };
    } else {
      enable = true;
      daemon.settings = lib.mkMerge [
        (lib.mkIf config.mySystem.docker.customDns {
          dns = config.mySystem.docker.dns;
          "dns-opts" = [ "ndots:0" ];
          "dns-search" = [];
        })
        {
          "iptables" = true;
          "ip-forward" = true;
        }
      ];
    };

    environment.systemPackages = with pkgs; 
      lib.optionals config.mySystem.docker.composePackage [ docker-compose ] ++
      lib.optionals config.mySystem.docker.rootless [ slirp4netns ];

    security.wrappers = lib.mkIf (config.mySystem.docker.rootless && config.mySystem.docker.enablePrivilegedPorts) {
      docker-rootlesskit = {
        owner = "root";
        group = "root";
        capabilities = "cap_net_bind_service+ep";
        source = "${pkgs.rootlesskit}/bin/rootlesskit";
      };
    };

    networking.firewall = {
      trustedInterfaces = [ "docker0" ] ++ lib.optional config.mySystem.docker.enable "br-*";
      checkReversePath = false;
      allowedUDPPorts = lib.optional config.mySystem.docker.customDns 53;
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };

    systemd.user.services = lib.mkIf (config.mySystem.docker.rootless && config.mySystem.docker.customDns) {
      docker-rootless-dns-config = {
        description = "Setup Docker rootless DNS configuration";
        wantedBy = [ "default.target" ];
        before = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "setup-docker-dns" ''
            mkdir -p ~/.config/docker
            cat > ~/.config/docker/daemon.json <<EOF
            {
              "dns": ${builtins.toJSON config.mySystem.docker.dns},
              "dns-opts": ["ndots:0"],
              "dns-search": [],
              "iptables": true,
              "ip-forward": true
            }
            EOF
          '';
        };
      };
    };
  };
}
