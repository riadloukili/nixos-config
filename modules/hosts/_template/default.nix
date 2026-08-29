# Template host (ignored by import-tree because of the `_` prefix).
# Copy this directory to modules/hosts/<name>/ and replace NAME.
# Names follow GAIA's subfunctions: aether artemis demeter hades hephaestus minerva poseidon.
{ config, ... }:
{
  flake.hosts.NAME = {
    provider = "home"; # or hetzner, aws, ...
    stateVersion = "26.11"; # the release you install with; never bump
    deploy.hostname = "NAME"; # remove for pull-only hosts
    modules = [ config.flake.modules.nixos.hosts-NAME ];
    hardwareModules = [
      config.flake.modules.nixos.hosts-NAME-hardware
      config.flake.modules.nixos.hosts-NAME-disk
    ];
  };

  flake.modules.nixos.hosts-NAME = {
    imports = [ config.flake.modules.nixos.roles-homelab ];
  };

  flake.modules.nixos.hosts-NAME-hardware =
    { modulesPath, ... }:
    {
      imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];
      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "nvme"
      ];
    };

  flake.modules.nixos.hosts-NAME-disk = config.flake.diskoLayouts.serverBtrfs {
    device = "/dev/nvme0n1";
  };
}
