# Everything every host gets. Roles are pure import lists.
{ config, ... }:
{
  flake.modules.nixos.roles-base = {
    imports = with config.flake.modules.nixos; [
      core-repo
      core-nix
      core-locale
      core-nh
      core-ssh
      core-sudo
      core-zsh
      core-zsh-wrapper
      core-packages
      core-gc
      core-home-manager
      core-users-riad
      secrets-sops
      secrets-user-password
    ];
    my.home.modules = with config.flake.modules.homeManager; [
      home-sops
      home-dotfiles
      home-cli
      home-neovim
      home-wrappers
    ];
  };
}
