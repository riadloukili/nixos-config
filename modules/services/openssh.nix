{ config, lib, pkgs, ... }:

{
  options = {
    mySystem.openssh = {
      enable = lib.mkEnableOption "OpenSSH server";
      
      passwordAuthentication = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable password authentication";
      };
      
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 22 ];
        description = "SSH ports to listen on";
      };
    };
  };

  config = lib.mkIf config.mySystem.openssh.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = config.mySystem.openssh.passwordAuthentication;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
      ports = config.mySystem.openssh.ports;
    };
  };
}