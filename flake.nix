{
  description = "Riad's NixOS machines";

  # Inputs only. Every .nix file in the directories below is a flake-parts
  # module (auto-imported by import-tree): ./lib is plumbing (the aspect
  # registry), ./outputs defines the flake outputs, the others register
  # NixOS / home-manager aspects (see lib/mods.nix).
  # Exception: under users/<name>/ only default.nix is loaded; the rest of
  # that folder is the user's own (home.nix, scripts, ...), imported by it.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree [
        ./lib
        ./outputs
        ./modules
        ./profiles
        (inputs.import-tree.filter (inputs.nixpkgs.lib.hasSuffix "default.nix") ./users)
        ./hosts
        ./installer
        ./disko
      ]
    );
}
