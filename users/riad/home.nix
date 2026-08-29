# riad's home-manager config. Shared pieces come from profiles
# (home-manager.sharedModules → home/*.nix); personal extras go here.
{ osConfig, ... }:
{
  home = {
    username = "riad";
    homeDirectory = "/home/riad";
    stateVersion = osConfig.system.stateVersion;
  };
  programs.home-manager.enable = true;
}
