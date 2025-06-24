{ config, pkgs, lib, options, ... }:

with lib;

options.mySystem.packages = mkOption {
  type = types.listOf types.package;
  default = [];
  description = "Additional system packages to install";
};

config.environment.systemPackages = config.environment.systemPackages ++ config.mySystem.packages;
