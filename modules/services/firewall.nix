{ config, lib, pkgs, ... }:

let
  portRangeType = lib.types.submodule {
    options = {
      from = lib.mkOption { type = lib.types.port; description = "Start of port range"; };
      to = lib.mkOption { type = lib.types.port; description = "End of port range"; };
    };
  };
in
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

      allowedTCPPortRanges = lib.mkOption {
        type = lib.types.listOf portRangeType;
        default = [];
        description = "List of TCP port ranges to allow";
      };

      allowedUDPPortRanges = lib.mkOption {
        type = lib.types.listOf portRangeType;
        default = [];
        description = "List of UDP port ranges to allow";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.mySystem.firewall.enable {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = config.mySystem.firewall.allowedTCPPorts;
        allowedUDPPorts = config.mySystem.firewall.allowedUDPPorts;
        allowedTCPPortRanges = config.mySystem.firewall.allowedTCPPortRanges;
        allowedUDPPortRanges = config.mySystem.firewall.allowedUDPPortRanges;
      };
    })
    (lib.mkIf (!config.mySystem.firewall.enable) {
      networking.firewall.enable = false;
    })
  ];
}