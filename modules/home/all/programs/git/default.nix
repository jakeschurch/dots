{
  pkgs,
  lib,
  config,
  ...
}:
let
  gitBin = lib.getExe pkgs.git;
  fzfBin = lib.getExe pkgs.fzf;
  git-license = pkgs.writeShellApplication {
    name = "git-license";
    runtimeInputs = with pkgs; [
      git
      curl
      jq
      coreutils
    ];
    text = builtins.readFile ./git-license.sh;
  };
  # Repositories whose GitHub copy is a read-only push mirror of Forgejo
  # (git.jakeschurch.com). A push to GitHub is rewritten to an unresolvable host
  # that names the right remote, so it fails before reaching GitHub; fetches are
  # untouched. Forgejo's own push mirror runs server-side and is unaffected.
  forgejoMirrored = [
    "homelab"
    "foundrybox"
    "statuspage"
    "argocd-tag-updater"
    "forgejo-operator"
    "harbor-operator"
    "margo"
    "microvm.nix"
  ];
  noGithubPush = builtins.listToAttrs (
    map (repo: {
      name = "https://read-only-github-mirror.invalid/push-to-git.jakeschurch.com-instead/${repo}";
      value.pushInsteadOf = [
        "https://github.com/jakeschurch/${repo}"
        "git@github.com:jakeschurch/${repo}"
        "ssh://git@github.com/jakeschurch/${repo}"
      ];
    }) forgejoMirrored
  );
  # Forgejo PAT for git over HTTPS, read when used from the Secret
  # forgejo-operator writes (ForgejoAccessToken forgejo/jake-workstation-human ->
  # Secret jake-workstation-token), so rotating it is a rotationNonce bump with no
  # copy to update. Cached 15 minutes under $XDG_RUNTIME_DIR; falls back to the
  # sops copy (/run/secrets/forgejo-git-token) when the cluster is unreachable.
  forgejo-git-credential = pkgs.writeShellApplication {
    name = "forgejo-git-credential";
    runtimeInputs = with pkgs; [
      kubectl
      coreutils
      findutils
    ];
    text = ''
      [ "''${1:-}" = get ] || exit 0
      cache="''${XDG_RUNTIME_DIR:-/tmp}/forgejo-git-token"
      token=""
      if [ -n "$(find "$cache" -mmin -15 2>/dev/null)" ]; then
        token=$(cat "$cache")
      else
        token=$(timeout 5 kubectl get secret -n forgejo jake-workstation-token \
          -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null || true)
        if [ -n "$token" ]; then
          (umask 077 && printf '%s' "$token" >"$cache")
        elif [ -r "$cache" ]; then
          token=$(cat "$cache")
        elif [ -r /run/secrets/forgejo-git-token ]; then
          token=$(cat /run/secrets/forgejo-git-token)
        fi
      fi
      [ -n "$token" ] && printf 'username=jake\npassword=%s\n' "$token"
    '';
  };
  difftastic-inline = pkgs.writeShellScriptBin "difftastic-inline" ''
    difft --display inline "$@"
  '';

  # tea's token: jake-agent-token (homelab forgejo-operator), whose scopes
  # include read:user/read:organization that tea needs to resolve the login.
  # Cached 15 min like forgejo-git-credential; falls back to the git token
  # (git-scoped only) when the cluster is unreachable.
  forgejo-tea-token = pkgs.writeShellApplication {
    name = "forgejo-tea-token";
    runtimeInputs = with pkgs; [
      kubectl
      coreutils
      findutils
      gnused
    ];
    text = ''
      cache="''${XDG_RUNTIME_DIR:-/tmp}/forgejo-tea-token"
      if [ -n "$(find "$cache" -mmin -15 2>/dev/null)" ]; then
        cat "$cache"
        exit 0
      fi
      token=$(timeout 5 kubectl get secret -n forgejo jake-agent-token \
        -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null || true)
      if [ -n "$token" ]; then
        (umask 077 && printf '%s' "$token" >"$cache")
      elif [ -r "$cache" ]; then
        token=$(cat "$cache")
      else
        token=$(${lib.getExe forgejo-git-credential} get | sed -n 's/^password=//p')
      fi
      printf '%s' "$token"
    '';
  };

  # Forgejo CLI. Logs in from env at call time so the token never lands in
  # ~/.config/tea/config.yml. An explicit GITEA_TOKEN skips the lookup.
  tea = pkgs.symlinkJoin {
    name = "tea-${pkgs.tea.version}";
    paths = [ pkgs.tea ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/tea --run '
        if [ -z "''${GITEA_TOKEN:-}" ]; then
          GITEA_TOKEN="$(${lib.getExe forgejo-tea-token})"
          if [ -n "$GITEA_TOKEN" ]; then
            export GITEA_LOGIN_VIA_ENV=1 GITEA_INSTANCE_URL=https://git.jakeschurch.com GITEA_TOKEN
          else
            unset GITEA_TOKEN
          fi
        fi
      '
    '';
  };
in
{
  home = {
    packages = with pkgs; [
      tea
      git-extras
      git-license
      difftastic
      difftastic-inline
      perlPackages.TermReadKey
      git-filter-repo
    ];

    shellAliases = {
      g = "git";
      gco = "git checkout";
      gs = "git switch -c";
    };

    file.".ssh/allowedSigners".text = ''
      jakeschurch@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXkQmmWeoRqR2jdPRH7PJN8QSpdofdf6hVxXtyMo1Vs
    '';
  };

  xdg.configFile = {
    "git/commit-template".source = ./git-commit-template;
    "git/gitignore".source = ./gitignore;
    "git/templates".source = ./templates;
  };

  programs = {
    git = {
      enable = true;
      package = pkgs.git;
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXkQmmWeoRqR2jdPRH7PJN8QSpdofdf6hVxXtyMo1Vs";
        format = "ssh";
        signByDefault = true;
      };

      settings = {
        user = {
          name = "Jake Schurch";
          email = "jakeschurch@gmail.com";
        };

        alias = {
          cleanenv = "clean -xfd -e .envrc";
          ai = "add --interactive";
          select-branch = "! f() { ${gitBin} checkout $(${gitBin} branch --all | ${fzfBin}); }; f";
          branchchanges = "! f() { ${gitBin} log --pretty=format:'%h %s' $(${gitBin} mainline)..$(${gitBin} head) ;}; f";
          delete = "branch -d";
          sc = "switch -c";
          c = "commit";
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
          mainline = "! git branch | grep -Eo 'main|master'";
        };
        gc.auto = 200;

        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowedSigners";

        advice.addIgnoredFile = false;

        commit = {
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
          # external diff set via GIT_EXTERNAL_DIFF by the shell wrappers below,
          # only when stdout is a tty, so piped output stays a plain patch
          # (https://github.com/Wilfred/difftastic/issues/965)
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
          ui = "auto";
          diff = "auto";
          status = "auto";
          branch = "auto";
          interactive = "auto";
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

        url = noGithubPush // {
          "ssh://git@github.com/".insteadOf = "https://github.com/";
          # Longest insteadOf prefix wins: keep noctalia's public plugin sources
          # on anonymous HTTPS. The shell fetches them from the Hyprland session,
          # whose SSH_AUTH_SOCK (gpg-agent) holds no keys, so the SSH rewrite
          # made every plugin update fail silently.
          "https://github.com/noctalia-dev/".insteadOf = "https://github.com/noctalia-dev/";

          # Forgejo is HTTPS + PAT only from workstations; there is no public SSH
          # route. Existing ssh:// remotes keep working through the rewrite.
          "https://git.jakeschurch.com/".insteadOf = [
            "ssh://git@git.jakeschurch.com/"
            "git@git.jakeschurch.com:"
          ];
        };
        credential."https://git.jakeschurch.com" = {
          username = "jake";
          helper = "${lib.getExe forgejo-git-credential}";
        };
      };
    };

    fish.functions.git = {
      wraps = "git";
      body = ''
        if isatty stdout
            GIT_EXTERNAL_DIFF=difftastic-inline command git $argv
        else
            command env -u GIT_EXTERNAL_DIFF git $argv
        end
      '';
    };

    zsh.initContent = ''
      git() {
        if [[ -t 1 ]]; then
          GIT_EXTERNAL_DIFF=difftastic-inline command git "$@"
        else
          command env -u GIT_EXTERNAL_DIFF git "$@"
        fi
      }
    '';

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
            title = "Inbox";
            filters = "org:fieldguide is:open involves:@me -author:@dependabot";
          }
          {
            title = "PR Reviews Needed";
            filters = "org:fieldguide is:open -is:draft
            review-requested:@me review-requested:Platform
            -author:@dependabot";
          }
          {
            title = "My PRs";
            filters = "is:open author:@me org:fieldguide draft:false";
          }
          {
            title = "My Draft PRs";
            filters = "is:open author:@me org:fieldguide draft:true";
          }
        ];
      };
    };
  };
}
