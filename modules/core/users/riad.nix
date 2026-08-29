# The primary user. One file per user; copy _template.nix to add another.
{
  flake.modules.nixos.core-users-riad =
    { config, ... }:
    {
      users.users.riad = {
        isNormalUser = true;
        description = "Riad Loukili";
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "input"
        ];
        # Keeps user services (e.g. rootless docker) running without a session.
        linger = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA155OrLNRsrX8you/OUX5l/gSrGl0HrfZ4NozYvngO/ riad@eleuthia"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAlLxIukRuOf8cR+IqnghXKScM6zkwXL5DoaHc6n5cOabI08RpbfbbIlc0Sz6EVUiB0pEbMtSdvgejjlR8Gr4ve49jj6t7E/4p9seTI9Cv8nsz69Eh10uP/m7I8BLWlXmQlHqSmVvrJz5H+gv7w0jlC4zETrYx3M2ayXFUAbjDEGnnSOoXGGroUVYed2mjlXAuGlhrxzmJWzyPk1H5AVmMjvphEVF6NqeruLO2Oo23r74yqqvDgvRhLEwGKFIUEnVdRnX9MIR0NoP4oBKbT1kxFt4J+bAC8u3MSkj3CRsDKAoug1eoLzc1XJ1NuDjQ0bpQyxVGv2LsbBJs0P1zOoGsuPP3//mMQeWVaEkNpFoiBMQeJydxGsIiyDzNVFbwwJX44hOlRKC/mfwmFYBE07wJ5BAtuqQ/zojT7WNn6n9Eflb5EA7oNrUzuaTJZCg3T45mtq3mIVQ0csVO+PpzzcKtCRgcGcSpVkf6UC/iEcyAXCy+euVgAc/UzZM5PGXzLk= riad@Riads-MacBook-Pro.local"
        ];
        # Password: set by modules/secrets/user-password.nix once the host has
        # secrets enrolled; until then the account is key-only.
      };

      home-manager.users.riad = {
        imports = config.my.home.modules;
        home = {
          username = "riad";
          homeDirectory = "/home/riad";
          stateVersion = config.system.stateVersion;
        };
        programs.home-manager.enable = true;
      };
    };
}
