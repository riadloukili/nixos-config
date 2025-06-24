{
  description = "Universal NixOS configurations (stable 25.05)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
  let
    # Function to discover hosts dynamically
    discoverHosts = hostsDir:
      let
        providers = builtins.attrNames (builtins.readDir hostsDir);
        
        # For each provider, get all machines
        getProviderMachines = provider:
          let
            providerDir = hostsDir + "/${provider}";
            allEntries = builtins.readDir providerDir;
            machines = builtins.filter (name: 
              (builtins.substring 0 1 name != ".") && 
              (allEntries.${name} == "directory")
            ) (builtins.attrNames allEntries);
          in
          builtins.listToAttrs (map (machine: {
            name = "${provider}-${machine}";
            value = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = { inputs = { inherit home-manager; }; };
              modules = [
                (providerDir + "/${machine}/configuration.nix")
              ];
            };
          }) machines);
      in
      builtins.foldl' (acc: provider: acc // (getProviderMachines provider)) {} providers;
  in
  {
    nixosConfigurations = discoverHosts ./hosts;
  };
}
