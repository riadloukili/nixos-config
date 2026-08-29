# eleuthia — personal laptop (ThinkPad Yoga).
{ config, ... }:
{
  flake.hosts.eleuthia = {
    provider = "home";
    stateVersion = "26.11";
    iso = "desktop";
    deploy.hostname = "eleuthia";
    modules = [ config.flake.modules.nixos.hosts-eleuthia ];
    hardwareModules = [
      config.flake.modules.nixos.hosts-eleuthia-hardware
      config.flake.modules.nixos.hosts-eleuthia-disk
    ];
  };

  flake.modules.nixos.hosts-eleuthia = {
    imports = with config.flake.modules.nixos; [
      roles-laptop
      hardware-intel
      hardware-thinkpad
      hardware-fingerprint
      hardware-convertible
    ];
    my.repo.localPath = "/home/riad/personal/nixos-config";
  };
}
