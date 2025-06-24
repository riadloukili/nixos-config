{ config, lib, pkgs, ... }:

{
  users.users.riad = {
    isNormalUser = true;
    # his SSH key
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAlLxIukRuOf8cR+IqnghXKScM6zkwXL5DoaHc6n5cOabI08RpbfbbIlc0Sz6EVUiB0pEbMtSdvgejjlR8Gr4ve49jj6t7E/4p9seTI9Cv8nsz69Eh10uP/m7I8BLWlXmQlHqSmVvrJz5H+gv7w0jlC4zETrYx3M2ayXFUAbjDEGnnSOoXGGroUVYed2mjlXAuGlhrxzmJWzyPk1H5AVmMjvphEVF6NqeruLO2Oo23r74yqqvDgvRhLEwGKFIUEnVdRnX9MIR0NoP4oBKbT1kxFt4J+bAC8u3MSkj3CRsDKAoug1eoLzc1XJ1NuDjQ0bpQyxVGv2LsbBJs0P1zOoGsuPP3//mMQeWVaEkNpFoiBMQeJydxGsIiyDzNVFbwwJX44hOlRKC/mfwmFYBE07wJ5BAtuqQ/zojT7WNn6n9Eflb5EA7oNrUzuaTJZCg3T45mtq3mIVQ0csVO+PpzzcKtCRgcGcSpVkf6UC/iEcyAXCy+euVgAc/UzZM5PGXzLk= riad@Riads-MacBook-Pro.local"
    ];
  };
}