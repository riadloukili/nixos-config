# Login password for the primary user, from secrets/common.yaml
# (`riad-password`, a `mkpasswd -m yescrypt` hash). Until the host has
# secrets enrolled the account is SSH-key only.
{
  flake.modules.nixos.secrets-user-password =
    { config, lib, ... }:
    lib.mkIf config.my.secrets.enable {
      sops.secrets.riad-password = {
        sopsFile = ../../secrets/common.yaml;
        neededForUsers = true;
      };
      users.users.riad.hashedPasswordFile = config.sops.secrets.riad-password.path;
    };
}
