# apollo — homelab server.
{ mods, ... }:
{
  flake.modules.nixos."hosts/apollo/default" = {
    imports = with mods.nixos; [
      profiles.server
      users.riad
      boot.systemd-boot
    ];

    system.stateVersion = "26.11";

    my.firewall.tcp = [
      80
      443
    ];
    my.autoUpdate.allowReboot = true;
  };
}
