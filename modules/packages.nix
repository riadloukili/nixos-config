{ config, lib, pkgs, types, ... }:

{
  options = {
    mySystem = {
      packages = lib.mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional system packages to install";
      };
    };
  };

  config = {
    environment.systemPackages =
      (config.environment.systemPackages or []) ++ config.mySystem.packages;
  };
}
