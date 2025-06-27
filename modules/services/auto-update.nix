{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.autoUpdate = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic system updates (enabled by default)";
      };
      
      time = lib.mkOption {
        type = lib.types.str;
        default = "02:00";
        description = "Time to run updates (24-hour format)";
      };
      
      flakeUri = lib.mkOption {
        type = lib.types.str;
        default = "github:riadloukili/nixos-config";
        description = "Flake URI to update from";
      };
      
      allowReboot = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow automatic reboot if required";
      };
    };
  };

  config = lib.mkIf config.mySystem.autoUpdate.enable {
    # Enable automatic updates
    system.autoUpgrade = {
      enable = true;
      flake = "${config.mySystem.autoUpdate.flakeUri}#${config.environment.variables.CLOUD_PROVIDER}-${config.networking.hostName}";
      flags = [
        "--refresh"
        "--no-write-lock-file"
        "-L" # print build logs
      ];
      dates = "daily";
      randomizedDelaySec = "45min";
      allowReboot = config.mySystem.autoUpdate.allowReboot;
    };

    # Set specific time using systemd timer
    systemd.timers.nixos-upgrade.timerConfig = {
      OnCalendar = lib.mkForce "*-*-* ${config.mySystem.autoUpdate.time}:00";
    };

    # Better logging configuration
    systemd.services.nixos-upgrade.serviceConfig = {
      StandardOutput = "journal";
      StandardError = "journal";
    };
    
    # Ensure system has git for flake operations
    environment.systemPackages = [ pkgs.git ];
  };
}