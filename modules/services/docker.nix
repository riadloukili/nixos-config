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
    };
  };

  config = lib.mkIf config.mySystem.docker.enable {
    virtualisation.docker = {
      enable = true;
      rootless = lib.mkIf config.mySystem.docker.rootless {
        enable = true;
        setSocketVariable = true;
      };
    };

    environment.systemPackages = lib.optionals config.mySystem.docker.composePackage [
      pkgs.docker-compose
    ];
  };
}