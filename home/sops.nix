# User-level secrets (secrets/user.yaml), decrypted with the user's own age key.
{
  flake.modules.homeManager.sops =
    { config, lib, ... }:
    let
      file = ../secrets/user.yaml;
    in
    lib.mkIf (builtins.pathExists file) {
      sops = {
        defaultSopsFile = file;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
