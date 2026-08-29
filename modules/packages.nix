# The minimal system-wide toolset; user tools live in home/.
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
}
