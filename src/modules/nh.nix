# nh (nix helper): rebuilds from `my.repo`, and its cleaner replaces nix.gc:
# keep the newest 5 generations *and* everything younger than 7 days, for the
# system and every user/home-manager profile.
{ mods, ... }:
{
  flake.modules.nixos."nh" =
    { config, lib, ... }:
    {
      imports = [ mods.nixos.repo ];

      programs.nh = {
        enable = true;
        flake = lib.defaultTo config.my.repo.uri config.my.repo.localPath;
        clean = {
          enable = true;
          dates = "03:00";
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };
      nix.settings.auto-optimise-store = true;
    };
}
