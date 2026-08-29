# zsh as the login shell for everyone (each user configures it in their own
# home-manager config); passwordless sudo for wheel; a minimal system toolset.
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    {
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.zsh;
      security.sudo.wheelNeedsPassword = false;
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
