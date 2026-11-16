{ lib, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      alias.conflicts = "diff --name-only --diff-filter=U --relative";
      branch.sort = "-committerdate";
      commit.verbose = "true";
      diff.algorithm = "histogram";
      diff.colorMoved = "true";
      diff.mnemonicPrefix = "true";
      fetch.all = "true";
      fetch.prune = "true";
      fetch.pruneTags = "true";
      grep.patternType = "perl";
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = "true";
      push.autoSetupRemote = "true";
      push.followTags = "true";
      rebase.autosquash = "true";
      rebase.autostash = "true";
      rebase.updateRefs = "true";
      tag.sort = "version:refname";
      user.email = lib.mkDefault "josheppinette@gmail.com";
      user.name = "Joshua Taylor Eppinette";
    };
  };
}
