{ config, lib, pkgs, ... }:

{
  options = {
    mySystem = {
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional system packages to install";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.mySystem.packages != []) {
      environment.systemPackages = config.mySystem.packages;
    })
  ];
}