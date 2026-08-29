{
  flake.wrappers.btop =
    { wlib, ... }:
    {
      imports = [ wlib.wrapperModules.btop ];
      settings = {
        vim_keys = true;
        color_theme = "Default";
        theme_background = false;
        update_ms = 1000;
      };
    };
}
