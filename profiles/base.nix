# Every machine.
{
  imports = [
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/nh.nix
    ../modules/ssh.nix
    ../modules/shell.nix
    ../modules/packages.nix
    ../modules/gc.nix
    ../modules/home-manager.nix
    ../modules/secrets.nix
  ];

  home-manager.sharedModules = [
    ../home/cli.nix
    ../home/neovim.nix
    ../home/wrappers.nix
    ../home/dotfiles.nix
    ../home/sops.nix
  ];
}
