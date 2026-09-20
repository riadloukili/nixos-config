# Fonts: Nerd Fonts for terminals/bar, Noto for coverage, Inter for UI, plus
# the families the web actually asks for so pages stop falling back.
{
  flake.modules.nixos."desktop/fonts" =
    { pkgs, ... }:
    {
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          # UI and terminal.
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          inter

          # Unicode coverage.
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          font-awesome

          # The Windows families, for real. A browser only accepts a font
          # whose own name is the one the page asked for; fontconfig's
          # catch-all match is rejected. So a stack of Windows font names
          # ending without a generic (login.microsoftonline.com does this)
          # matches nothing and lands on the default serif. Installing the
          # names makes them resolve.
          corefonts # Arial, Verdana, Georgia, Trebuchet MS, Times New Roman, Courier New, Impact
          carlito # metric-compatible Calibri
          caladea # metric-compatible Cambria

          # What the rest of the web asks for, roughly by usage.
          roboto
          open-sans
          lato
          montserrat
          poppins
          nunito
          raleway
          oswald
          source-sans-pro
          source-serif-pro
          work-sans
          public-sans
          merriweather
          fira
          ubuntu-sans
        ];
        # The UI families with no free equivalent. A browser will not accept
        # fontconfig's catch-all for a name it cannot match; it takes only a
        # font that really carries the requested name, or one an alias names
        # outright. Microsoft's and Apple's stacks end without a generic
        # family, so without these they land on the default serif.
        fontconfig.localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <alias binding="same">
              <family>Segoe UI</family>
              <accept><family>Inter</family></accept>
            </alias>
            <alias binding="same">
              <family>Segoe UI Variable</family>
              <accept><family>Inter</family></accept>
            </alias>
            <alias binding="same">
              <family>Helvetica Neue</family>
              <accept><family>Inter</family></accept>
            </alias>
            <alias binding="same">
              <family>Lucida Grande</family>
              <accept><family>Inter</family></accept>
            </alias>
            <alias binding="same">
              <family>SF Pro Text</family>
              <accept><family>Inter</family></accept>
            </alias>
            <alias binding="same">
              <family>SF Pro Display</family>
              <accept><family>Inter</family></accept>
            </alias>
            <!-- Windows' script-specific UI faces; Noto covers the scripts. -->
            <alias binding="same">
              <family>Ebrima</family>
              <accept><family>Noto Sans</family></accept>
            </alias>
            <alias binding="same">
              <family>Nirmala UI</family>
              <accept><family>Noto Sans</family></accept>
            </alias>
            <alias binding="same">
              <family>Gadugi</family>
              <accept><family>Noto Sans</family></accept>
            </alias>
            <alias binding="same">
              <family>Meiryo UI</family>
              <accept><family>Noto Sans CJK JP</family></accept>
            </alias>
            <alias binding="same">
              <family>Malgun Gothic</family>
              <accept><family>Noto Sans CJK KR</family></accept>
            </alias>
            <alias binding="same">
              <family>Microsoft YaHei UI</family>
              <accept><family>Noto Sans CJK SC</family></accept>
            </alias>
            <alias binding="same">
              <family>Microsoft JhengHei UI</family>
              <accept><family>Noto Sans CJK TC</family></accept>
            </alias>
          </fontconfig>
        '';

        fontconfig.defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font" ];
          sansSerif = [ "Inter" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
