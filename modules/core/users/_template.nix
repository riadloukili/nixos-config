# Template for an additional user. Files starting with `_` are ignored by
# import-tree: copy this to `<name>.nix`, fill it in, and add
# `core-users-<name>` to a role or host import list.
{
  flake.modules.nixos.core-users-NAME =
    { config, ... }:
    {
      users.users.NAME = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
      };

      home-manager.users.NAME = {
        imports = config.my.home.modules;
        home = {
          username = "NAME";
          homeDirectory = "/home/NAME";
          stateVersion = config.system.stateVersion;
        };
        programs.home-manager.enable = true;
      };
    };
}
