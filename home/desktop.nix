# Desktop session basics: theming, cursor, a few apps, xdg dirs.
{
  flake.modules.homeManager."desktop" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        brave
        mpv
        imv
        zathura
        xdg-utils
      ];

      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      gtk = {
        enable = true;
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };

      xdg = {
        enable = true;
        userDirs.enable = true;
        mimeApps.enable = true;
      };
    };
}
