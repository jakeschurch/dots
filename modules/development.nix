{
  pkgs,
  lib,
  config,
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
        _1password
        gh

        act
        gnused

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
        kubectx
        kubernetes-helm
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
      ++ (lib.optionals pkgs.stdenv.isDarwin [
        arc-browser
      ])
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

        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh &
      '';
    };

    zsh = {
      enable = true;
      defaultKeymap = "vicmd";
      enableCompletion = lib.mkForce true;
      syntaxHighlighting = {
        enable = true;
        highlighters = ["brackets"];
      };
      autosuggestion.enable = true;
      initExtraBeforeCompInit = ''
        export ZSH_COMPDUMP=~/.zcompdump
        fpath+=(/etc/static/profiles/per-user/jake/share/zsh/site-functions /etc/static/profiles/per-user/jake/share/zsh/$ZSH_VERSION/functions /etc/static/profiles/per-user/jake/share/zsh/ /etc/static/profiles/per-user/jake/share/zsh/vendor-completions)
      '';
      autocd = true;
      history = {
        size = 100000;
        path = "${config.xdg.dataHome}/zsh/history";
        extended = true;
      };
      envExtra = ''
        export AWS_PROFILE="fg-staging"
        export AWS_REGION="us-west-2"
        export PG_VERSION="15"
      '';
      initExtra = ''
        setopt autocd

        bindkey "''${key[Up]}" up-line-or-search
        bindkey '^I' expand-or-complete

        source <(colima completion zsh) &
        source <(kubectl completion zsh) &
        eval "$(direnv hook zsh)" &
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh &
        autopair-init &

        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line
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
      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings
      '';
      plugins = with pkgs.fishPlugins; [
        autopair
      ];
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

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
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
