# Everyday command-line tools for every host.
{
  flake.modules.homeManager.home-cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        curl
        wget
        tree
        unzip
        ripgrep
        fd
        bat
        eza
        jq
        yq-go
        dust
        duf
        fastfetch
      ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        fzf.enable = true;
        zoxide.enable = true;
        atuin = {
          enable = true;
          flags = [ "--disable-up-arrow" ];
        };
      };
    };
}
