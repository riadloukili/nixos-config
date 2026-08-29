# OpenSSH server, key-only.
{
  flake.modules.nixos.ssh = {
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
