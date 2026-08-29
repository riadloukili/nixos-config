# Pull-based updates: the host rebuilds itself from `my.repo.uri` daily.
# Pushing to main therefore deploys to every host with this aspect.
{
  flake.modules.nixos.services-auto-update =
    { config, lib, ... }:
    let
      cfg = config.my.autoUpdate;
    in
    {
      options.my.autoUpdate = {
        enable = lib.mkEnableOption "daily self-update from the repo" // {
          default = true;
        };
        time = lib.mkOption {
          type = lib.types.str;
          default = "02:00";
          description = "Daily run time (HH:MM); randomised by up to 45 minutes.";
        };
        allowReboot = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Reboot automatically when the kernel or initrd changed.";
        };
      };

      config = lib.mkIf cfg.enable {
        system.autoUpgrade = {
          enable = true;
          flake = "${config.my.repo.uri}#${config.networking.hostName}";
          flags = [
            "--refresh"
            "--no-write-lock-file"
            "-L"
          ];
          dates = "*-*-* ${cfg.time}:00";
          randomizedDelaySec = "45min";
          inherit (cfg) allowReboot;
        };
      };
    };
}
