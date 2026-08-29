# nh (nix helper) + where this machine's configuration comes from.
# `my.repo.uri` is also the pull target of modules/auto-update.nix.
{
  flake.modules.nixos.nh =
    { config, lib, ... }:
    {
      options.my.repo = {
        uri = lib.mkOption {
          type = lib.types.str;
          default = "github:riadloukili/nixos-config";
          description = "Flake URI machines pull their configuration from.";
        };
        localPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/home/riad/personal/nixos-config";
          description = "Local checkout to prefer for interactive rebuilds (nh), if any.";
        };
      };

      config.programs.nh = {
        enable = true;
        flake = if config.my.repo.localPath != null then config.my.repo.localPath else config.my.repo.uri;
        clean.enable = false;
      };
    };
}
