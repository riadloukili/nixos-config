# The minimal system-wide toolset (root needs these too); everything else is per user.
{
  flake.modules.nixos."packages" =
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
