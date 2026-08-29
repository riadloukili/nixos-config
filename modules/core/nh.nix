# nh (nix helper): `nh os switch`, `nh home switch`, diff + build tree output.
# Cleaning is left to modules/core/gc.nix.
{
  flake.modules.nixos.core-nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = if config.my.repo.localPath != null then config.my.repo.localPath else config.my.repo.uri;
        clean.enable = false;
      };
    };
}
