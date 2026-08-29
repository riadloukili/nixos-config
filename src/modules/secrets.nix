# sops-nix: the decryption mechanism only. The host decrypts with the age key
# derived from its SSH host key. Consumers declare their own secrets and pick
# the file by scope:
#   secrets/common.yaml         everything (every host and every user)
#   secrets/hosts/common.yaml   every host          secrets/hosts/<name>.yaml   one host
#   secrets/users/common.yaml   every user          secrets/users/<name>.yaml   one user
# Use `my.secrets.file "users/riad.yaml"` (null while the file does not exist),
# so a fresh host builds before anything is enrolled.
{
  flake.modules.nixos."secrets" =
    { config, lib, ... }:
    let
      dir = ../../secrets;
      file = rel: if builtins.pathExists (dir + "/${rel}") then dir + "/${rel}" else null;
      hostFile = file "hosts/${config.networking.hostName}.yaml";
      hostCommon = file "hosts/common.yaml";
      common = file "common.yaml";
    in
    {
      options.my.secrets = {
        enable = lib.mkEnableOption "decrypting sops secrets on this host" // {
          default = common != null || hostCommon != null || hostFile != null;
        };
        file = lib.mkOption {
          type = lib.types.functionTo (lib.types.nullOr lib.types.path);
          default = file;
          readOnly = true;
          description = "Path of secrets/<rel> if it exists, else null.";
        };
      };

      config = lib.mkIf config.my.secrets.enable {
        sops = {
          # Most specific file present; consumers still set sopsFile explicitly.
          defaultSopsFile = lib.mkIf (hostFile != null || hostCommon != null || common != null) (
            lib.defaultTo (lib.defaultTo common hostCommon) hostFile
          );
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
        environment.systemPackages = [ config.sops.package ];
      };
    };
}
