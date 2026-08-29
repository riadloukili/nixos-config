# User-side session basics common to every compositor: GTK/Qt theming,
# cursor, and a few desktop apps.
{
  flake.modules.homeManager.home-desktop-session =
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
