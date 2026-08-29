# NetworkManager for roaming machines.
{
  flake.modules.nixos.desktop-networkmanager = {
    networking.networkmanager.enable = true;
  };
}
