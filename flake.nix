{
  description = "Universal NixOS configurations (stable 25.05)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      # Hetzner
      "hetzner-eu-lite-nix-1" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inputs = { inherit home-manager; }; };
        modules = [
          ./hosts/hetzner/eu-lite-nix-1/configuration.nix
        ];
      };
    };
  };
}
