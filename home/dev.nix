# Development tooling for workstations.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    glab
    just
    nodejs
    python3
    uv
    go
    rustup
    docker-compose
    lazydocker
  ];
  programs = {
    ghostty.enable = true;
    kitty.enable = true;
  };
}
