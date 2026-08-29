# apollo — homelab server.
{
  imports = [
    ../../../profiles/server.nix
    ../../../users/riad.nix
    ../../../modules/boot/systemd-boot.nix
  ];

  system.stateVersion = "26.11";

  my.firewall.tcp = [
    80
    443
  ];
  my.autoUpdate.allowReboot = true;
}
