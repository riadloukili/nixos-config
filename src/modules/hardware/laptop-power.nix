# Battery and lid behaviour.
{
  flake.modules.nixos."hardware/laptop-power" = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
      logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "ignore";
        HandlePowerKey = "suspend";
      };
    };
  };
}
