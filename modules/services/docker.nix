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
