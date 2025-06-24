{
  description = "Universal NixOS configurations (stable 25.05)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # Hetzner
      "hetzner-eu-lite-nix-1" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/packages.nix
          ./modules/users
          ./profiles/base.nix
          ./hosts/hetzner/eu-lite-nix-1/configuration.nix
        ];
      };
    };
  };
}
