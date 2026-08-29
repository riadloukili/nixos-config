# Overlays applied to every host: `pkgs.stable.<x>` / `pkgs.unstable.<x>` for
# pinning a single package to the other channel.
{ inputs, ... }:
{
  flake.overlays.default = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
    unstable = import inputs.nixpkgs {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  flake.modules.nixos.core-overlays = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
  };
}
