{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.garbageCollection = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic garbage collection (enabled by default)";
      };
      
      deleteOlderThan = lib.mkOption {
        type = lib.types.str;
        default = "7d";
        description = "Delete generations older than this (e.g., 7d, 30d)";
      };
      
      time = lib.mkOption {
        type = lib.types.str;
        default = "03:00";
        description = "Time to run garbage collection (24-hour format)";
      };
    };
  };

  config = lib.mkIf config.mySystem.garbageCollection.enable {
    # Enable automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than ${config.mySystem.garbageCollection.deleteOlderThan} --delete-generations +5";
    };

    # Set specific time using systemd timer
    systemd.timers.nix-gc.timerConfig = {
      OnCalendar = lib.mkForce "*-*-* ${config.mySystem.garbageCollection.time}:00";
    };

    # Better logging configuration
    systemd.services.nix-gc.serviceConfig = {
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}