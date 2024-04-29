{pkgs, ...}: let
  gitBin = "${pkgs.git}/bin/git";
  fzfBin = "${pkgs.fzf}/bin/fzf";
in {
  # git dependencies
  home.packages = with pkgs; [
    git-extras
    perlPackages.TermReadKey
  ];

  programs.git = {
    enable = true;
    userName = "Jake Schurch";
    userEmail = "jakeschurch@gmail.com";
    signing = {key = "6A8B32A193C5727F7ED7CBCEDCE52B50B91728F9";};
    aliases = {
      ai = "add --interactive";
      select-branch = "! f() { ${gitBin} checkout $(${gitBin} branch --all | ${fzfBin}); }; f";
      branchchanges = "! f() { ${gitBin} log --pretty=format:'%h %s' $(${gitBin} mainbranch)..$(${gitBin} head) ;}; f";
      delete = "branch -d";
      sc = "switch -c";
      c = "! f() { ~/bin/git/abbrevs.sh git-commit $@; }; f";
      ca = "commit --amend";
      co = "checkout";
      empty = "commit --allow-empty";
      fixup = "commit --fixup";
      noedit = "commit --amend --no-edit";
      fp = "push --force-with-lease";
      grep = "grep --break --heading";
      hard = "reset --hard HEAD";
      mixed = "reset --mixed HEAD^";
      ignore = "! curl -sL https://www.gitignore.io/api/$@ >> .gitignore";
      lg = "log --abbrev-commit --date=short";
      lgo = "log  --abbrev-commit --date=short --oneline --graph";
      ls = "status -suno";
      r = "! f() { ~/bin/git/abbrevs.sh git-rebase $@; }; f ";
      ra = "rebase --abort";
      rc = "rebase --continue";
      ri = "rebase --interactive";
      rs = "rebase --skip";
      who = "shortlog -s -e -";
      revs = "! f() { ~/bin/git/abbrevs.sh git-revs $@ ;}; f";
      top = "rev-parse --show-toplevel";
      mainbranch = "! f() { ~/bin/git/abbrevs.sh git-mainbranch $@ ;}; f";
    };
    includes = [
      {
        path = "~/.config/git/config.work";
        condition = "gitdir:~/Projects/work/jf";
      }
    ];
    extraConfig = {
      gc.auto = 200;

      commit = {
        gpgSign = false;
        verbose = true;
        template = "~/.config/git/commit-template";
      };

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      pull = {
        twohead = "ort";
        rebase = true;
      };

      format.signOff = true;

      protocol.version = "2";

      github.user = "jakeschurch";

      rebase = {
        interactive = true;
        autosquash = true;
      };

      interactive.singleKey = true;

      diff = {
        tool = "neovim";
        colorMoved = "default";
        algorithm = "minimal";
      };

      merge = {
        conflictstyle = "diff3";
      };

      mergetool = {
        keepBackup = false;
        fugitive = {cmd = ''nvim -f -c "Gvdiffsplit!" "$MERGED"'';};
      };

      log = {
        abbrevCommit = true;
        showSignature = false;
      };

      color = {
        ui = "always";
        diff = "auto";
        status = "always";
        branch = "auto";
        interactive = "always";
        grep = "auto";
        decorate = "auto";
        showbranch = "auto";
      };

      core = {
        abbrev = "6";
        excludesfile = "~/.config/git/gitignore";
        editor = "nvim";
        preloadIndex = true;
        untrackedCache = true;
        fsmonitor = true;
        commitgraph = true;
      };

      status = {submodulessummary = "1";};
      checkout = {defaultRemote = "origin";};
      remote = {origin = {prune = true;};};
      rerere = {enabled = true;};
      grep = {extendedRegexp = true;};
      init = {defaultBranch = "main";};
      branch = {sort = "committerdate";};
      column = {ui = "always";};
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
    };

    delta = {
      enable = true;

      options = {
        features = "side-by-side line-numbers decorations whitespace-error-style = 22 reverse";
        line-numbers = true;
        side-by-side = true;
        hyperlinks = true;
        hyperlinks-file-link-format = "file-line://{path}:{line}";
        dark = true;
        plus-style = "syntax #012800";
        minus-style = "syntax #340001";
        syntax-theme = "Monokai Extended";
        navigate = true;
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          hunk-header-decoration-style = "cyan ul";
        };
      };
    };
  };
  xdg = {
    configFile = {
      "git/config.work".text = "[user]\nemail = jakeschurch@gmail.com\n";
      "git/commit-template".source = ./git-commit-template;
      "git/gitignore".source = ./gitignore;
    };
  };
}
