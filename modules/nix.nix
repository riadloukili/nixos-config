# Nix daemon settings and nixpkgs policy.
{ inputs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      warn-dirty = false;
    };
    # `nix run nixpkgs#foo` uses the same nixpkgs as the system.
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    optimise.automatic = lib.mkDefault false; # done by modules/gc.nix
  };

  nixpkgs.config.allowUnfree = true;
}
