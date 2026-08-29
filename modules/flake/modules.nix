# Enables `flake.modules.<class>.<name>` (dendritic pattern).
#
# Every file under modules/ registers one or more named aspects here, e.g.
#   flake.modules.nixos.core-ssh = { ... };
#   flake.modules.homeManager.home-cli = { ... };
# A host is then just an import list of those names (see modules/hosts/).
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
