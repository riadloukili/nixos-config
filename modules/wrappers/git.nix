# git with identity and defaults baked in (GIT_CONFIG_GLOBAL). Only ever
# installed for the user — never put this in an overlay as `git`.
{
  flake.wrappers.git =
    { wlib, pkgs, ... }:
    {
      imports = [ wlib.wrapperModules.git ];

      settings = {
        user = {
          name = "Riad Loukili";
          email = "me@riad.ca";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autoStash = true;
        fetch.prune = true;
        diff.colorMoved = "default";
        merge.conflictStyle = "zdiff3";
        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        delta = {
          navigate = true;
          line-numbers = true;
        };
        alias = {
          st = "status -sb";
          co = "checkout";
          sw = "switch";
          lg = "log --oneline --graph --decorate -20";
        };
      };
    };
}
