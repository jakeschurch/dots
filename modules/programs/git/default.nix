{pkgs, ...}: let
  gitBin = "${pkgs.git}/bin/git";
  fzfBin = "${pkgs.fzf}/bin/fzf";
  difftastic-inline = pkgs.writeShellScriptBin "difftastic-inline" ''
    difft --display inline "$@"
  '';
in {
  # git dependencies
  home.packages = with pkgs; [
    git-extras
    difftastic
    difftastic-inline
    perlPackages.TermReadKey
  ];

  home.shellAliases = {
    g = "git";
    gco = "git checkout";
    gs = "git switch -c";
  };

  programs.git = {
    enable = true;
    package = pkgs.unstable.git;
    userName = "Jake Schurch";
    userEmail = "jakeschurch@gmail.com";
    signing = {
      key = "6A8B32A193C5727F7ED7CBCEDCE52B50B91728F9";
    };
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
      lastupdated = "log -1 --format='%ad' --";
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
        condition = "gitdir:~/Projects/work";
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

      difftool = {
        prompt = false;
        difftastic = {
          cmd = "difftastic-inline \"$LOCAL\" \"$REMOTE\"";
        };
      };

      pager = {
        difftool = true;
      };

      diff = {
        tool = "neovim";
        colorMoved = "default";
        algorithm = "minimal";
        external = "difftastic-inline";
        sopsdiffer = {
          textconv = "sops -d";
        };
      };

      merge = {
        conflictstyle = "diff3";
      };

      mergetool = {
        keepBackup = false;
        fugitive = {
          cmd = ''nvim -f -c "Gvdiffsplit!" "$MERGED"'';
        };
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
        fsmonitor = false;
        commitgraph = true;
      };

      status = {
        submodulessummary = "1";
      };
      checkout = {
        defaultRemote = "origin";
      };
      remote = {
        origin = {
          prune = true;
        };
      };
      rerere = {
        enabled = true;
      };
      grep = {
        extendedRegexp = true;
      };
      init = {
        defaultBranch = "main";
        templateDir = "~/.config/git/templates";
      };
      branch = {
        sort = "committerdate";
      };
      column = {
        ui = "always";
      };
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
    };
  };

  xdg = {
    configFile = {
      "git/config.work".text = ''
        [user]
          name = Jake Schurch
          email = jakeschurch@gmail.com
          signingkey = D43F2816596BFF67F80B049651BD69A43BB80786
      '';
      "git/commit-template".source = ./git-commit-template;
      "git/gitignore".source = ./gitignore;
      "git/templates".source = ./templates;
    };
  };
}
