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
      rawFile = rel: if builtins.pathExists (dir + "/${rel}") then dir + "/${rel}" else null;
      hostFile = rawFile "hosts/${config.networking.hostName}.yaml";
      hostCommon = rawFile "hosts/common.yaml";
      common = rawFile "common.yaml";
    in
    {
      options.my.secrets = {
        enable = lib.mkEnableOption "decrypting sops secrets on this host" // {
          default = common != null || hostCommon != null || hostFile != null;
        };
        # Null when the file is missing or secrets are disabled (live ISOs), so
        # guarded consumers declare nothing and the ISO carries no sops manifest.
        file = lib.mkOption {
          type = lib.types.functionTo (lib.types.nullOr lib.types.path);
          default = rel: if config.my.secrets.enable then rawFile rel else null;
          readOnly = true;
          description = "Path of secrets/<rel> if it exists and secrets are enabled, else null.";
        };
        # sops files list their keys in cleartext, so a key's presence can be
        # checked at eval time: a secret whose key is not enrolled yet stays
        # undeclared instead of failing sops-nix's build-time validation.
        key = lib.mkOption {
          type = lib.types.functionTo (lib.types.functionTo (lib.types.nullOr lib.types.path));
          default =
            rel: name:
            let
              f = config.my.secrets.file rel;
            in
            if f != null && lib.hasInfix "${name}:" (builtins.readFile f) then f else null;
          readOnly = true;
          description = "Path of secrets/<rel> if it exists and contains <name>, else null.";
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
