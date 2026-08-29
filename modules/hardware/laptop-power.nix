# Battery and lid behaviour.
{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend";
    };
  };
}
