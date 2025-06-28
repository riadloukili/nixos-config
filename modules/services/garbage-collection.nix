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
      
      keepGenerations = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Minimum number of generations to keep";
      };
      
      time = lib.mkOption {
        type = lib.types.str;
        default = "03:00";
        description = "Time to run garbage collection (24-hour format)";
      };
    };
  };

  config = lib.mkIf config.mySystem.garbageCollection.enable {
    # Disable the default nix.gc since we're creating our own
    nix.gc.automatic = false;

    # Create custom garbage collection service
    systemd.services.nix-gc-custom = {
      description = "Nix Garbage Collection with generation limits";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      script = ''
        set -eu
        
        echo "Starting custom Nix garbage collection..."
        
        # Keep minimum number of system generations
        echo "Keeping last ${toString config.mySystem.garbageCollection.keepGenerations} system generations..."
        ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +${toString config.mySystem.garbageCollection.keepGenerations} || true
        
        # Delete generations older than specified time
        echo "Deleting generations older than ${config.mySystem.garbageCollection.deleteOlderThan}..."
        ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than ${config.mySystem.garbageCollection.deleteOlderThan}
        
        # Optimize store
        echo "Optimizing Nix store..."
        ${pkgs.nix}/bin/nix-store --optimise
        
        echo "Garbage collection completed."
      '';
    };

    # Create timer for the custom service
    systemd.timers.nix-gc-custom = {
      description = "Timer for custom Nix garbage collection";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* ${config.mySystem.garbageCollection.time}:00";
        Persistent = true;
        RandomizedDelaySec = "15m";  # Add some jitter
      };
    };

    # Also manage bootloader generations if using systemd-boot or GRUB
    boot.loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable config.mySystem.garbageCollection.keepGenerations;
    boot.loader.grub.configurationLimit = lib.mkIf config.boot.loader.grub.enable config.mySystem.garbageCollection.keepGenerations;
  };
}