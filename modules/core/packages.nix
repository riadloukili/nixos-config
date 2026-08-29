# The minimal system-wide toolset. Everything user-facing lives in
# home-manager aspects (modules/home) or wrappers (modules/wrappers).
{
  flake.modules.nixos.core-packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        vim
        htop
        curl
        kitty.terminfo
        ghostty.terminfo
      ];
    };
}
