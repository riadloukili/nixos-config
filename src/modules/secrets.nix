# sops-nix: the decryption mechanism only. The host decrypts with the age key
# derived from its SSH host key; each consumer declares its own secret under
# `lib.mkIf config.my.secrets.enable` (users/riad/default.nix, tailscale.nix).
# Inert until secrets/common.yaml exists, so a fresh host builds before it is
# enrolled (`just sops-add-host <name> <ip>`).
{
  flake.modules.nixos."secrets" =
    { config, lib, ... }:
    let
      common = ../../secrets/common.yaml;
      hostFile = ../../secrets + "/${config.networking.hostName}.yaml";
    in
    {
      options.my.secrets = {
        enable = lib.mkEnableOption "decrypting sops secrets on this host" // {
          default = builtins.pathExists common;
        };
        commonFile = lib.mkOption {
          type = lib.types.path;
          default = common;
          readOnly = true;
          description = "secrets/common.yaml, readable by every enrolled host.";
        };
      };

      config = lib.mkIf config.my.secrets.enable {
        sops = {
          defaultSopsFile = if builtins.pathExists hostFile then hostFile else common;
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
        environment.systemPackages = [ config.sops.package ];
      };
    };
}
