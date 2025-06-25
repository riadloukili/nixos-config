{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.networking = {
      enable = lib.mkEnableOption "custom networking configuration";
      
      nameservers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "9.9.9.9" ];
        description = "List of DNS nameservers to use";
      };
    };
  };

  config = lib.mkIf config.mySystem.networking.enable {
    networking.nameservers = config.mySystem.networking.nameservers;
  };
}