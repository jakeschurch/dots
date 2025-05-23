{
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages =
      with pkgs;
      [
        (pkgs.callPackage ./vectorcode.nix { })
        python3Packages.chromadb
        (pkgs.callPackage ./kubectl-jq.nix { })
        pipx
        nix-update
        ssm-session-manager-plugin
        kind
        # latex
        # texlive.combined.scheme-medium
        # _1password-cli
        ffmpeg
        mtr

        sshuttle

        chafa
        act

        procs
        gnused
        gnugrep

        moreutils
        cloudflared
        tmux
        mosh

        bat
        bat-extras.batdiff
        bat-extras.batgrep
        bat-extras.batwatch
        bat-extras.batman
        bat-extras.prettybat
        wget
        lsd

        terraform
        asciinema
        asciinema-agg

        k9s
        kubectl
        kubectx
        kubernetes-helm
        kubernetes-helmPlugins.helm-diff
        kubelogin-oidc

        lazydocker
        docker-credential-helpers
        pass
        colima
        docker-compose

        jq
        tealdeer
        direnv
        nix-direnv
        nix-tree

        sd
        tokei
        (aspellWithDicts (
          ds: with ds; [
            en
            en-computers
            en-science
          ]
        ))
        coreutils
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
        obs-studio
        nixgl.nixGLIntel
        steam
        rofi
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

  xdg.configFile = {
    "vale/vale.ini".text = ''
      [core]
      Vocab = en

      [checks]
      Vale.Avoid = true
      Vale.Spelling = true
      proselint = true
      write-good = true

      [*.{md,txt}]
      Vale.Avoid = true
      Vale.Spelling = true

      [*.{tex}]
      Vale.TeX = true
    '';
  };

  programs = {
    zathura.enable = true;

    nix-index.enable = true;
    command-not-found.enable = false;

    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };

    nix-your-shell = {
      enable = true;
      enableZshIntegration = true;
    };

    readline = {
      enable = true;

      extraConfig = ''
        set editing-mode vi
        set convert-meta on
        set show-all-if-ambiguous on
        set horizontal-scroll-mode Off
        set bell-style none
        set keymap vi-command

        # Color files by types
        # Note that this may cause completion text blink in some terminals (e.g. xterm).
        set colored-stats On

        # Append char to indicate type
        set visible-stats On

        # Mark symlinked directories
        set mark-symlinked-directories On

        # Color the common prefix
        set colored-completion-prefix On

        # Color the common prefix in menu-complete
        set menu-complete-display-prefix On

        # Enable case-insensitive completion
        set completion-ignore-case On

        # Enable incremental searching (like in vim)
        set show-mode-in-prompt On

        # Bind 'Ctrl-r' to search history incrementally (like in vim)
        "\C-r": reverse-search-history

        # Bind 'Ctrl-f' to open the current line in an editor (like in vim)
        "vv": edit-and-execute-command

        "k": history-search-backward
        "j": history-search-forward

        # Bind 'h' and 'l' to move left and right in command mode
        "h": backward-char
        "l": forward-char

        # Bind '/' to incremental search forward
        "/": history-search-forward

        # Bind '?' to incremental search backward
        "?": history-search-backward

        # Bind 'Ctrl-l' to clear the screen (like in vim)
        "\C-l": clear-screen
      '';
    };

    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        set -o vi

        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh &
      '';
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
      defaultCommand = "rg --files --hidden --no-heading --height 40% --pcre2 --ignore-file=~/.rgignore";
      defaultOptions = [
        "--extended"
        "--cycle"
      ];
      historyWidgetOptions = [
        "--sort"
        "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
      ];
      fileWidgetCommand = "fd --type f --ignore --hidden";
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
        rust = {
          symbol = "🦀 ";
        };
        hostname = {
          ssh_only = true;
          format = "on [$hostname](bold red) ";
        };
        cmd_duration = {
          min_time = 300000;
        };
        aws = {
          disabled = false;
          symbol = "☁️ ";
        };
        kubernetes = {
          disabled = false;
          contexts = [
            {
              context_pattern = ".*/(?<cluster>fg-.*?)";
              context_alias = "$cluster";
              symbol = "🚢 ";
            }
          ];
        };
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
