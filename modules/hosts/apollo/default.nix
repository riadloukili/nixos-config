# apollo — homelab server at home.
{ config, ... }:
{
  flake.hosts.apollo = {
    provider = "home";
    stateVersion = "26.11";
    deploy.hostname = "apollo";
    modules = [ config.flake.modules.nixos.hosts-apollo ];
    hardwareModules = [
      config.flake.modules.nixos.hosts-apollo-hardware
      config.flake.modules.nixos.hosts-apollo-disk
    ];
  };

  flake.modules.nixos.hosts-apollo = {
    imports = [ config.flake.modules.nixos.roles-homelab ];
    my.firewall.tcp = [
      80
      443
    ];
    my.autoUpdate.allowReboot = true;
  };
}
