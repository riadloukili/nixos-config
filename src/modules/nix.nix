# Nix daemon settings and nixpkgs policy.
{
  flake.modules.nixos."nix" =
    { inputs, ... }:
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
          # A flake's own nixConfig is ignored when it is used as an input, so
          # numtide's cache has to be declared here or their Rust packages
          # (codex) build from source.
          substituters = [
            "https://nix-community.cachix.org"
            "https://cache.numtide.com"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
          warn-dirty = false;
        };
        # `nix run nixpkgs#foo` uses the same nixpkgs as the system. A github ref,
        # not `flake = inputs.nixpkgs`: that would make the whole nixpkgs source a
        # runtime dependency of every system closure.
        registry.nixpkgs.to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          inherit (inputs.nixpkgs.sourceInfo) rev narHash lastModified;
        };
        nixPath = [ "nixpkgs=flake:nixpkgs" ];
      };

      nixpkgs.config.allowUnfree = true;
    };
}
