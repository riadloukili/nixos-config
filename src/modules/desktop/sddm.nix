# SDDM with the sddm-astronaut theme, colours and background as on
# ceres (JaKooLit's "simple_sddm_2" is this theme). Password at the greeter;
# fingerprint is for hyprlock/sudo.
{
  flake.modules.nixos."desktop/sddm" =
    { pkgs, ... }:
    let
      theme =
        (pkgs.sddm-astronaut.override {
          themeConfig = {
            Background = "Backgrounds/riad.png";
            FontSize = "13";
            KeyboardSize = "0.4";
            RoundCorners = "20";
            HourFormat = "hh:mm AP";
            DateFormat = "dddd d MMMM";
            DimBackground = "0.0";
            CropBackground = true;
            BackgroundHorizontalAlignment = "center";
            BackgroundVerticalAlignment = "center";
            HeaderTextColor = "#694327";
            DateTextColor = "#694327";
            TimeTextColor = "#694327";
            FormBackgroundColor = "#24152A";
            BackgroundColor = "#24152A";
            DimBackgroundColor = "#24152A";
            LoginFieldBackgroundColor = "#24152A";
            PasswordFieldBackgroundColor = "#24152A";
            LoginFieldTextColor = "#34251C";
            PasswordFieldTextColor = "#34251C";
            UserIconColor = "#82502B";
            PasswordIconColor = "#82502B";
            PlaceholderTextColor = "#82502B";
            WarningColor = "#343746";
            LoginButtonTextColor = "#ffffff";
            LoginButtonBackgroundColor = "#24152A";
            SystemButtonsIconsColor = "#694327";
            SessionButtonTextColor = "#694327";
            VirtualKeyboardButtonTextColor = "#694327";
            DropdownTextColor = "#ffffff";
            DropdownSelectedBackgroundColor = "#694327";
            DropdownBackgroundColor = "#444242";
            HighlightTextColor = "#211C1A";
            HighlightBackgroundColor = "#34251C";
            HighlightBorderColor = "#343746";
            HoverUserIconColor = "#82502B";
            HoverPasswordIconColor = "#82502B";
            HoverSystemButtonsIconsColor = "#694327";
            HoverSessionButtonTextColor = "#694327";
            HoverVirtualKeyboardButtonTextColor = "#694327";
            PartialBlur = true;
            BlurMax = "32";
            HaveFormBackground = false;
            FormPosition = "left";
            VirtualKeyboardPosition = "center";
            HideVirtualKeyboard = false;
            HideSystemButtons = false;
            HideLoginButton = false;
            ForceLastUser = true;
            PasswordFocus = true;
            HideCompletePassword = true;
            AllowEmptyPassword = false;
            AllowUppercaseLettersInUsernames = false;
            BypassSystemButtonsChecks = false;
            RightToLeftLayout = false;
          };
        }).overrideAttrs
          (old: {
            postInstall = (old.postInstall or "") + ''
              chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
              install -m 644 ${./sddm-background.png} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/riad.png
            '';
          });
    in
    {
      services.displayManager.sddm = {
        enable = true;
        # The greeter runs under X11: SDDM's Wayland greeter draws no pointer on
        # this machine. Sessions themselves are unaffected (Hyprland is Wayland).
        wayland.enable = false;
        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs.kdePackages; [
          qtsvg
          qtmultimedia
          qtvirtualkeyboard
        ];
        settings = {
          General.InputMethod = "qtvirtualkeyboard";
          # Without a cursor theme the Wayland greeter shows no pointer at all.
          Theme = {
            CursorTheme = "Bibata-Modern-Ice";
            CursorSize = 24;
          };
        };
      };
      services.xserver.enable = true; # the X11 greeter needs it; sessions stay Wayland
      environment.systemPackages = [
        theme
        pkgs.bibata-cursors
      ];
      security.pam.services.sddm.fprintAuth = false;
    };
}
