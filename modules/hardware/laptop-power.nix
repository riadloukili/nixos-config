# Battery and lid behaviour.
{
  flake.modules.nixos.hardware-laptop-power = {
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend";
    };
  };
}
