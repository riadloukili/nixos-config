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
    virtualisation.docker = if config.mySystem.docker.rootless then {
      enable = false;  # Disable system-wide daemon for rootless
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
  };
}