{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.firewall = {
      enable = lib.mkEnableOption "firewall";
      
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of TCP ports to allow";
      };
      
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "List of UDP ports to allow";
      };
    };
  };

  config = lib.mkIf config.mySystem.firewall.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = config.mySystem.firewall.allowedTCPPorts;
      allowedUDPPorts = config.mySystem.firewall.allowedUDPPorts;
    };
  };
}