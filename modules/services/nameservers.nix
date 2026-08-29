# Static upstream resolvers.
{
  flake.modules.nixos.services-nameservers =
    { lib, ... }:
    {
      networking.nameservers = lib.mkDefault [
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
}
