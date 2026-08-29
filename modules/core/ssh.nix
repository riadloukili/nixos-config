# OpenSSH server, key-only.
{
  flake.modules.nixos.core-ssh =
    { lib, ... }:
    {
      options.my.ssh.ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 22 ];
        description = "Ports sshd listens on (also opened in the firewall).";
      };

      config = {
        services.openssh = {
          enable = true;
          ports = lib.mkDefault [ 22 ];
          openFirewall = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
            X11Forwarding = false;
          };
        };
      };
    };
}
