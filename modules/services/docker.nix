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
    };
  };

  config = lib.mkIf config.mySystem.docker.enable {
    virtualisation.docker = if config.mySystem.docker.rootless then {
      enable = false;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    } else {
      enable = true;
    };

    environment.systemPackages = lib.optionals config.mySystem.docker.composePackage [
      pkgs.docker-compose
    ];

    systemd.services.docker-rootless-setcap = lib.mkIf (config.mySystem.docker.rootless && config.mySystem.docker.enablePrivilegedPorts) {
      description = "Set CAP_NET_BIND_SERVICE on rootlesskit for Docker rootless";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.libcap}/bin/setcap cap_net_bind_service=ep ${pkgs.rootlesskit}/bin/rootlesskit";
      };
      before = [ "docker.service" ];
    };
  };
}
