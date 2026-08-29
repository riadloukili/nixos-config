# nix-wrapper-modules: programs bundled with their config as plain packages.
# Every `flake.wrappers.<name>` is also exported as `packages.<system>.<name>`,
# so `nix run github:riadloukili/nixos-config#tmux` works on any Nix machine.
{ inputs, ... }:
{
  imports = [ inputs.wrappers.flakeModules.wrappers ];
}
