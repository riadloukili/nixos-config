# riad: the system user. Everything else about me is in ./home.nix
# (home-manager) and the dotfiles repo (github:riadloukili/dotfiles).
#
# My identity lives in secrets/users/riad.yaml: `password` (mkpasswd hash),
# `ssh-private-key` and `ssh-public-key` — my single SSH keypair. A host listed
# on that file gets them at boot; home.nix installs the pair in ~/.ssh.
# (authorized_keys below must be known at evaluation time, so the public key
# is repeated there.)
{ mods, ... }:
{
  flake.modules.nixos."users/riad" =
    { config, lib, ... }:
    let
      secrets = config.my.secrets.file "users/riad.yaml";
      # Paid fonts (Comic Code): an encrypted tarball, unpacked by home.nix.
      fonts = config.my.secrets.file "users/riad/fonts.tar.xz";
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ3v/KMk1F3kqL6Rgav+J7+PEjYv+ogqeY+t6N5V7pQ+ riad"
        ];
        hashedPasswordFile = lib.mkIf (secrets != null) config.sops.secrets.riad-password.path;
      };

      sops.secrets = lib.mkMerge [
        (lib.mkIf (secrets != null) {
          riad-password = {
            sopsFile = secrets;
            key = "password";
            neededForUsers = true;
          };
          riad-ssh-key = {
            sopsFile = secrets;
            key = "ssh-private-key";
            owner = "riad";
          };
          riad-ssh-key-pub = {
            sopsFile = secrets;
            key = "ssh-public-key";
            owner = "riad";
            mode = "0444";
          };
        })
        (lib.mkIf (fonts != null) {
          riad-fonts = {
            sopsFile = fonts;
            format = "binary";
            owner = "riad";
          };
        })
      ];

      home-manager.users.riad = ./home.nix;
    };
}
