# Where this machine's configuration comes from: the pull target of
# auto-update.nix and the flake nh rebuilds from.
{
  flake.modules.nixos."repo" =
    { lib, ... }:
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
    };
}
