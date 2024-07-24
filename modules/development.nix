{
  pkgs,
  lib,
  ...
}: let
  download-nixpkgs-cache-index = pkgs.writeShellScriptBin "download-nixpkgs-cache-index" ''
    download_nixpkgs_cache_index() {
    	filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
    	mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    	# -N will only download a new version if there is an update.
    	wget -q -N https://github.com/Mic92/nix-index-database/releases/latest/download/"$filename"
    	ln -f "$filename" files
    }

    download_nixpkgs_cache_index
  '';
in {
  home = {
    packages = with pkgs;
      [
        download-nixpkgs-cache-index
        # latex
        # texlive.combined.scheme-medium

        yabai
        moreutils
        cloudflared
        tmux
        mosh

        bat
        bat-extras.batdiff
        bat-extras.batgrep
        bat-extras.batman
        bat-extras.batwatch
        bat-extras.prettybat
        wget
        lsd
        k9s
        kubectl

        kubelogin-oidc
        docker
        lazydocker
        docker-credential-helpers
        pass
        colima

        jq
        tealdeer
        direnv
        nix-direnv
        fd
        sd
        tokei
        (aspellWithDicts (ds: with ds; [en en-computers en-science]))
        (ripgrep.override {withPCRE2 = true;})
        coreutils
        man
        expect
        difftastic

        arion

        sops
        ssh-to-pgp
        gnupg

        cachix

        ctags

        pre-commit

        yq

        awscli2
        entr
        watch
        grex
        nix-output-monitor
        nvd
        bc
        gotop
        ccache
      ]
      ++ (lib.optionals pkgs.stdenv.isLinux [
        nixgl.nixGLIntel
        rofi
        etcher
        postgresql_16
        spotify
        docker
        wmctrl
        xbanish
        playerctl
        xbindkeys
        xautolock
        yubikey-manager
        ethtool
        # xev-1.2.4
      ]);

    file."Documents/Templates" = {
      source = ../Templates;
      recursive = true;
    };

    file.".isort.cfg".text = ''
      [settings]
      multi_line_output=3
      including_trailing_comma=True
      balanced_wrapping=True
      sections=FUTURE,STDLIB,THIRDPARTY,PANDAS,FIRSTPARTY,LOCALFOLDER
      line_length=100
      force_to_top=True
    '';
  };

  programs = {
    zathura.enable = true;

    command-not-found.enable = false;
    nix-index.enable = true;
    info.enable = true;

    bash = {
      enable = true;
      bashrcExtra = ''
        set -o vi

        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };

    zsh = {
      enable = true;
      defaultKeymap = "vicmd";
      enableCompletion = lib.mkForce true;
      syntaxHighlighting.enable = true;
      enableAutosuggestions = true;
      initExtraBeforeCompInit = ''
        export ZSH_COMPDUMP=~/.zcompdump
        fpath+=(/etc/static/profiles/per-user/jake/share/zsh/site-functions /etc/static/profiles/per-user/jake/share/zsh/$ZSH_VERSION/functions /etc/static/profiles/per-user/jake/share/zsh/ /etc/static/profiles/per-user/jake/share/zsh/vendor-completions )
        # workaround for site-functions completion bug
        source <(cat /etc/static/profiles/per-user/jake/share/zsh/site-functions/_*) 2>/dev/null 1>&2
      '';
      initExtra = ''
        setopt autocd

        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

        bindkey "''${key[Up]}" up-line-or-search
        ZSH_HIGHLIGHT_HIGHLIGHTERS+=brackets

        bindkey '^I' expand-or-complete

        # source <(colima completion zsh)
        source <(kubectl completion zsh)
        eval "$(direnv hook zsh)"

        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line

        export AWS_PROFILE="fg-staging"
        export AWS_REGION="us-west-2"
        export PG_VERSION="15"

        autopair-init
      '';
      zplug = {
        enable = true;
        plugins = [
          {name = "hlissner/zsh-autopair";}
        ];
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "fzf"
          "git"
          "history-substring-search"
          "vi-mode"
        ];
      };
    };

    fish = {
      enable = false;
      shellInit = ''
        fish_vi_key_bindings
      '';
    };

    fzf = {
      enable = true;
      defaultCommand = "rg --files --hidden --no-heading --height 40% --pcre2";
      defaultOptions = [
        "--extended"
        "--cycle"
      ];
      historyWidgetOptions = [
        "--sort"
        "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
      ];
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
      ];
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
        aliases = {
          prdiff = "pr diff --patch";
          myprs = "prlist --author=@me | awk '{print $1}' | xargs -n 1 gh prview";
          prlist = "pr list --state=open \"$@\"";
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableIonIntegration = false;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[ ♥ ](bold red)";
          error_symbol = "[ 💔](bold red)";
          vicmd_symbol = "[ 💎](bold blue)";
        };
        rust = {symbol = "🦀 ";};
        hostname = {
          ssh_only = true;
          format = "on [$hostname](bold red) ";
        };
        cmd_duration = {min_time = 300000;};
        aws = {disabled = false;};
        time = {
          disabled = false;
          use_12hr = true;
        };

        git_state.disabled = true;
        git_status.disabled = true;
        java.disabled = true;
        nodejs.disabled = true;
        package.disabled = true;
        ruby.disabled = true;
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}
