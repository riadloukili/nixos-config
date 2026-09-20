# /bin and /usr/bin populated from $PATH at runtime (envfs), so scripts with
# `#!/bin/bash`-style shebangs (dotfiles, downloaded tools) run unchanged.
{
  flake.modules.nixos."desktop/envfs" = {
    services.envfs.enable = true;
  };
}
