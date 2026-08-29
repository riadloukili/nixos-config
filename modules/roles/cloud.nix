# Cloud VM: server role on a BIOS/hybrid-boot disk (see hardware/disko/cloud-bios.nix).
{ config, ... }:
{
  flake.modules.nixos.roles-cloud = {
    imports = with config.flake.modules.nixos; [
      roles-server
      core-boot-grub
    ];
  };
}
