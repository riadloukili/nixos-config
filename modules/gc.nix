# Garbage collection that keeps the newest N generations *and* only deletes
# older ones past an age threshold, then collects garbage and optimises.
{
  flake.modules.nixos.gc =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.gc;
    in
    {
      options.my.gc = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        keepGenerations = lib.mkOption {
          type = lib.types.ints.positive;
          default = 5;
          description = "Never delete the newest N system generations.";
        };
        deleteOlderThan = lib.mkOption {
          type = lib.types.str;
          default = "7d";
          description = "Older generations beyond the newest N are deleted past this age.";
        };
        time = lib.mkOption {
          type = lib.types.str;
          default = "03:00";
        };
      };

      config = lib.mkIf cfg.enable {
        nix.gc.automatic = false;

        systemd.services.nix-gc-generations = {
          description = "Nix garbage collection (keep ${toString cfg.keepGenerations}, older than ${cfg.deleteOlderThan})";
          path = with pkgs; [
            nix
            gawk
            coreutils
            gnugrep
          ];
          serviceConfig.Type = "oneshot";
          script = ''
            set -eu
            profile=/nix/var/nix/profiles/system
            keep=${toString cfg.keepGenerations}
            threshold=$(date -d "${cfg.deleteOlderThan} ago" +%s)
            gens=$(nix-env --profile "$profile" --list-generations)
            if [ "$(echo "$gens" | wc -l)" -gt "$keep" ]; then
              echo "$gens" | sort -k1,1nr | tail -n +"$((keep + 1))" | while read -r gen date time _; do
                ts=$(date -d "$date $time" +%s 2>/dev/null || echo 0)
                if [ "$ts" -gt 0 ] && [ "$ts" -lt "$threshold" ]; then
                  echo "deleting generation $gen ($date $time)"
                  nix-env --profile "$profile" --delete-generations "$gen"
                fi
              done
            fi
            nix-collect-garbage
            nix-store --optimise
          '';
        };

        systemd.timers.nix-gc-generations = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*-*-* ${cfg.time}:00";
            Persistent = true;
            RandomizedDelaySec = "15m";
          };
        };

        boot.loader.systemd-boot.configurationLimit = lib.mkDefault (cfg.keepGenerations * 2);
        boot.loader.grub.configurationLimit = lib.mkDefault (cfg.keepGenerations * 2);
      };
    };
}
