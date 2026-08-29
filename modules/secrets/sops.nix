# sops-nix wiring. The host decrypts with the age key derived from its SSH
# host key; the user's home-manager secrets use ~/.config/sops/age/keys.txt.
#
# Enrol a host: `just sops-add-host <name> <ssh-host>` (see justfile).
# Secrets files are only wired in once they exist, so a fresh host builds
# before it has been enrolled.
{ inputs, ... }:
{
  flake.modules.nixos.secrets-sops =
    { config, lib, ... }:
    let
      hostFile = ../../secrets + "/${config.networking.hostName}.yaml";
      commonFile = ../../secrets/common.yaml;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      options.my.secrets.enable = lib.mkOption {
        type = lib.types.bool;
        default = builtins.pathExists commonFile;
        description = "Whether this host decrypts sops secrets (true once secrets/common.yaml exists).";
      };

      config = lib.mkIf config.my.secrets.enable {
        sops = {
          defaultSopsFile = if builtins.pathExists hostFile then hostFile else commonFile;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
        environment.systemPackages = [ config.sops.package ];
      };
    };

  flake.modules.homeManager.home-sops =
    { config, lib, ... }:
    let
      userFile = ../../secrets/user.yaml;
    in
    lib.mkIf (builtins.pathExists userFile) {
      sops = {
        defaultSopsFile = userFile;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
