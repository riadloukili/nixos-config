# Headless machine that runs services and updates itself.
{ config, ... }:
{
  flake.modules.nixos.roles-server = {
    imports = with config.flake.modules.nixos; [
      roles-base
      services-docker
      services-firewall
      services-auto-update
      services-nameservers
    ];
  };
}
