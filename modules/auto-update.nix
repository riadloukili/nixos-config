# Pull-based updates: rebuild daily from `my.repo.uri` (pushing to main deploys).
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
    };
    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
}
