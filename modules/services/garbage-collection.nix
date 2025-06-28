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
        
        PROFILE="/nix/var/nix/profiles/system"
        MIN_KEEP=${toString config.mySystem.garbageCollection.keepGenerations}
        DELETE_OLDER_THAN="${config.mySystem.garbageCollection.deleteOlderThan}"
        
        # Get all generations sorted by number (newest first)
        ALL_GENS=$(${pkgs.nix}/bin/nix-env --profile "$PROFILE" --list-generations | ${pkgs.gawk}/bin/awk '{print $1}' | sort -nr)
        TOTAL_GENS=$(echo "$ALL_GENS" | wc -l)
        
        echo "Total generations: $TOTAL_GENS"
        echo "Minimum to keep: $MIN_KEEP"
        
        if [ "$TOTAL_GENS" -le "$MIN_KEEP" ]; then
          echo "Not enough generations to perform any cleanup (have $TOTAL_GENS, need to keep $MIN_KEEP)"
        else
          # Get the newest N generations that we must keep
          KEEP_GENS=$(echo "$ALL_GENS" | head -n "$MIN_KEEP")
          echo "Will always keep these generations (newest $MIN_KEEP): $(echo $KEEP_GENS | tr '\n' ' ')"
          
          # Get generations that are candidates for deletion (older than newest N)
          CANDIDATE_GENS=$(echo "$ALL_GENS" | tail -n +"$((MIN_KEEP + 1))")
          
          if [ -n "$CANDIDATE_GENS" ]; then
            echo "Candidate generations for time-based deletion: $(echo $CANDIDATE_GENS | tr '\n' ' ')"
            
            # Create a temporary script to check each candidate generation's age
            TEMP_SCRIPT=$(mktemp)
            cat > "$TEMP_SCRIPT" << 'EOF'
        #!/bin/bash
        PROFILE="$1"
        GEN="$2"
        DELETE_OLDER_THAN="$3"
        
        # Get the date of this generation
        GEN_DATE=$(nix-env --profile "$PROFILE" --list-generations | grep "^$GEN " | awk '{print $2, $3, $4, $5}')
        if [ -n "$GEN_DATE" ]; then
          # Convert to timestamp and check if it's older than threshold
          GEN_TIMESTAMP=$(date -d "$GEN_DATE" +%s 2>/dev/null || echo "0")
          THRESHOLD_TIMESTAMP=$(date -d "$DELETE_OLDER_THAN ago" +%s)
          
          if [ "$GEN_TIMESTAMP" -lt "$THRESHOLD_TIMESTAMP" ] && [ "$GEN_TIMESTAMP" -gt "0" ]; then
            echo "$GEN"
          fi
        fi
        EOF
            chmod +x "$TEMP_SCRIPT"
            
            # Find which candidate generations are actually old enough to delete
            GENS_TO_DELETE=""
            for gen in $CANDIDATE_GENS; do
              if OLD_GEN=$("$TEMP_SCRIPT" "$PROFILE" "$gen" "$DELETE_OLDER_THAN"); then
                if [ -n "$OLD_GEN" ]; then
                  GENS_TO_DELETE="$GENS_TO_DELETE $OLD_GEN"
                fi
              fi
            done
            
            rm "$TEMP_SCRIPT"
            
            if [ -n "$GENS_TO_DELETE" ]; then
              echo "Deleting generations that are both old enough AND not in newest $MIN_KEEP:$GENS_TO_DELETE"
              for gen in $GENS_TO_DELETE; do
                echo "Deleting generation $gen..."
                ${pkgs.nix}/bin/nix-env --profile "$PROFILE" --delete-generations "$gen"
              done
            else
              echo "No generations are old enough to delete (all candidates are newer than $DELETE_OLDER_THAN)"
            fi
          else
            echo "No candidate generations for deletion (only keeping minimum $MIN_KEEP)"
          fi
        fi
        
        # Now run garbage collection to clean up the store
        echo "Running garbage collection to clean up unreferenced store paths..."
        ${pkgs.nix}/bin/nix-collect-garbage
        
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
        RandomizedDelaySec = "15m";
      };
    };

    # Set reasonable bootloader limits
    boot.loader.systemd-boot.configurationLimit = lib.mkIf config.boot.loader.systemd-boot.enable 
      (config.mySystem.garbageCollection.keepGenerations * 2);
    boot.loader.grub.configurationLimit = lib.mkIf config.boot.loader.grub.enable 
      (config.mySystem.garbageCollection.keepGenerations * 2);
  };
}