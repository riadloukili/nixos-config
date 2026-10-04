# OpenSSH: key-only server, plus an agent so the passphrase is typed once per
# login instead of on every git fetch/push (AddKeysToAgent caches the key the
# first time ssh-askpass asks for it).
{
  flake.modules.nixos."ssh" = {
    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };
  };
}
