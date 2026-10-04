# zsh as the login shell for everyone; each user configures it in their own home-manager config.
{
  flake.modules.nixos."shell" =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;
    };
}
