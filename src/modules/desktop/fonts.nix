# Fonts: Nerd Fonts for terminals/bar, Noto for coverage, Inter for UI.
{
  flake.modules.nixos."desktop/fonts" =
    { pkgs, ... }:
    {
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          font-awesome
          inter
        ];
        fontconfig.defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "Inter" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
