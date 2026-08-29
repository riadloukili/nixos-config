# riad: the system user. Everything else about me is in ./home.nix
# (home-manager) and the dotfiles repo (github:riadloukili/dotfiles).
{ mods, ... }:
{
  flake.modules.nixos."users/riad" =
    { config, lib, ... }:
    let
      secrets = config.my.secrets.file "users/riad.yaml";
    in
    {
      imports = [ mods.nixos.secrets ];

      users.users.riad = {
        isNormalUser = true;
        description = "Riad Loukili";
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "input"
        ];
        linger = true; # keeps user services (rootless docker) alive without a session
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA155OrLNRsrX8you/OUX5l/gSrGl0HrfZ4NozYvngO/ riad@eleuthia"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAlLxIukRuOf8cR+IqnghXKScM6zkwXL5DoaHc6n5cOabI08RpbfbbIlc0Sz6EVUiB0pEbMtSdvgejjlR8Gr4ve49jj6t7E/4p9seTI9Cv8nsz69Eh10uP/m7I8BLWlXmQlHqSmVvrJz5H+gv7w0jlC4zETrYx3M2ayXFUAbjDEGnnSOoXGGroUVYed2mjlXAuGlhrxzmJWzyPk1H5AVmMjvphEVF6NqeruLO2Oo23r74yqqvDgvRhLEwGKFIUEnVdRnX9MIR0NoP4oBKbT1kxFt4J+bAC8u3MSkj3CRsDKAoug1eoLzc1XJ1NuDjQ0bpQyxVGv2LsbBJs0P1zOoGsuPP3//mMQeWVaEkNpFoiBMQeJydxGsIiyDzNVFbwwJX44hOlRKC/mfwmFYBE07wJ5BAtuqQ/zojT7WNn6n9Eflb5EA7oNrUzuaTJZCg3T45mtq3mIVQ0csVO+PpzzcKtCRgcGcSpVkf6UC/iEcyAXCy+euVgAc/UzZM5PGXzLk= riad@Riads-MacBook-Pro.local"
        ];
        # Password: `password` in secrets/users/riad.yaml (`mkpasswd -m yescrypt`); key-only until it exists.
        hashedPasswordFile = lib.mkIf (secrets != null) config.sops.secrets.riad-password.path;
      };

      sops.secrets.riad-password = lib.mkIf (secrets != null) {
        sopsFile = secrets;
        key = "password";
        neededForUsers = true;
      };

      home-manager.users.riad = ./home.nix;
    };
}
