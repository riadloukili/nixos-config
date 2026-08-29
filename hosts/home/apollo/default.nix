# apollo — homelab server.
{ mods, ... }:
{
  flake.modules.nixos.host-apollo = {
    imports = with mods.nixos; [
      profile-server
      user-riad
      boot-systemd-boot
    ];

    system.stateVersion = "26.11";

    my.firewall.tcp = [
      80
      443
    ];
    my.autoUpdate.allowReboot = true;
  };
}
