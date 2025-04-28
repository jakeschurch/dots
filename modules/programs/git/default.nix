{
  pkgs,
  lib,
  ...
}:
let
  gitBin = lib.getExe pkgs.git;
  fzfBin = lib.getExe pkgs.fzf;
  difftastic-inline = pkgs.writeShellScriptBin "difftastic-inline" ''
    difft --display inline "$@"
  '';
in
{
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

  xdg.configFile = {
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

  programs = {
    git = {
      enable = true;
      package = pkgs.git;
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
        file-branches = "!f() { git log --all --branches --oneline --decorate -- \"$1\" | head -n 20; }; f";
        file-stashes = "!f() { git stash list --format=\"%gd %s\" | awk '{print $1}' | xargs -I{} sh -c 'git show --name-only {} | grep -q \"$1\" && echo {}'; }; f";
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
        mainbranch = "! git branch | grep -Eo 'main|master'";
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
          nvimdiff = {
            cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
            prompt = false;
          };
        };

        pager = {
          difftool = true;
        };

        diff = {
          tool = "difftastic";
          colorMoved = "default";
          algorithm = "minimal";
          external = "difftastic-inline";
          sopsdiffer = {
            textconv = "sops -d";
          };
        };

        merge = {
          tool = "nvimmerge";
          conflictstyle = "diff3";
        };

        mergetool = {
          keepBackup = false;
          fugitive = {
            cmd = ''nvim -f -c "DiffViewOpen" "$MERGED"'';
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

    gh.enable = true;
    gh-dash = {
      enable = true;
      settings = {
        keybindings.prs = [
          {
            key = "esc";
            builtin = null;
          }
        ];
        theme = {
          colors = {
            background = {
              selected = "#3c3836";
            };
            border = {
              faint = "#282828";
              primary = "#504945";
              secondary = "#665c54";
            };
            text = {
              faint = "#7c6f64";
              inverted = "#282828";
              primary = "#ebdbb2";
              secondary = "#d5c4a1";
              success = "#98971a";
              warning = "#cc241d";
            };
          };
          ui = {
            sectionsShowCount = true;
            table = {
              compact = true;
              showSeparators = true;
            };
          };
        };
        defaults = {
          preview = {
            open = true;
            width = 65;
            grow = false;
          };
          view = "prs";
          layout.prs = {
            updatedAt.hidden = true;
            base.hidden = true;
            assignees.hidden = true;
            author.hidden = true;
            repo.width = 18;
            lines.width = 9;
            title.grow = true;
          };
        };
        prSections = [
          {
            title = "My PRs";
            filters = "is:open author:@me org:fieldguide draft:false";
          }
          {
            title = "My Draft PRs";
            filters = "is:open author:@me org:fieldguide draft:true";
          }
          {
            title = "PR Reviews Needed";
            filters = "org:fieldguide is:open -is:draft
            review-requested:@me review-requested:Platform
            -author:@dependabot";
          }
        ];
      };
    };
  };
}
