# sops-nix. The host decrypts with the age key derived from its SSH host key.
# Only active once secrets/common.yaml exists, so a fresh host builds before
# it is enrolled (`just sops-add-host <name> <ip>`).
#
# Secrets in common.yaml: riad-password (mkpasswd -m yescrypt hash),
# tailscale-auth-key (when tailscale is enabled).
{
  flake.modules.nixos."secrets" =
    { config, lib, ... }:
    let
      common = ../secrets/common.yaml;
      hostFile = ../secrets + "/${config.networking.hostName}.yaml";
    in
    {
      options.my.secrets.enable = lib.mkOption {
        type = lib.types.bool;
        default = builtins.pathExists common;
        description = "Whether this host decrypts sops secrets.";
      };

      config = lib.mkIf config.my.secrets.enable {
        sops = {
          defaultSopsFile = if builtins.pathExists hostFile then hostFile else common;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

          secrets.riad-password = {
            sopsFile = common;
            neededForUsers = true;
          };
          secrets.tailscale-auth-key = lib.mkIf config.services.tailscale.enable { sopsFile = common; };
        };

        users.users.riad.hashedPasswordFile = config.sops.secrets.riad-password.path;
        services.tailscale.authKeyFile = lib.mkIf config.services.tailscale.enable config.sops.secrets.tailscale-auth-key.path;
        environment.systemPackages = [ config.sops.package ];
      };
    };
}
