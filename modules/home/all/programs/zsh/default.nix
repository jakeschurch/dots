{
  config,
  lib,
  pkgs,
  ...
}:
let
  zsh-completions = import ./zsh-completions.nix {
    inherit pkgs lib;
    packages = with pkgs; [
      colima
    ];
  };

  homeFileReferences =
    builtins.listToAttrs (
      map (completion: {
        name = ".cache/zsh/completions/_${completion.pname}";
        value = {
          source = "${completion}/_${completion.pname}";
        };
      }) zsh-completions
    )
    // {
      ".cache/zsh/completions/_command-not-found" = {
        source = "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
      };
    };
in
{
  home.file = homeFileReferences;

  home.activation.rebuildZcompdump = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f ~/.zcompdump
    zsh -c 'autoload -Uz compinit && compinit -i' 2>/dev/null || true
  '';

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.zsh = {
    zprof.enable = false;
    enable = true;
    enableCompletion = lib.mkForce true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
      ];
    };
    autosuggestion.enable = true;
    autocd = true;
    history = {
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
      extended = true;
    };
    envExtra = ''
      export AWS_PROFILE="fg-sso-staging-administrator-access"
      export PG_VERSION="15"
    '';
    completionInit = ''
      autoload -Uz compinit
      compinit -i -C
    '';

    initExtraBeforeCompInit = ''
      export ZSH_COMPDUMP=~/.zcompdump
      fpath+=(
        ~/.cache/zsh/completions
        "${config.home.profileDirectory}/share/zsh/site-functions"
      )
    '';

    initExtra = ''
      autoload -Uz bracketed-paste-magic
      zle -N bracketed-paste bracketed-paste-magic

      function calc() {
        python3 -c "print(eval('$*'))"
      }

      # AWS Profile Switcher with fzf
      function awsp() {
        local profile
        sso_profiles=$(grep -E '^\[profile ' ~/.aws/config | sed 's/^\[profile \(.*\)\]/\1/')
        cred_profiles=$(grep -E '^\[profile ' ~/.aws/credentials | sed 's/^\[profile \(.*\)\]/\1/')

        profile_selections=$({
          echo "$sso_profiles"
          echo "$cred_profiles"
        } | uniq)

        profile=$(echo $profile_selections | fzf --height 40% --prompt="AWS Profile> ")

        if [[ -n "$profile" ]]; then
          export AWS_PROFILE="$profile"
          echo "✓ AWS_PROFILE set to: $profile"
        fi
      }

      function kctx() {
        local context
        context=$(kubectl config get-contexts -o name | fzf --height 40% --reverse --prompt="K8s Context> ")

        if [[ -n "$context" ]]; then
          kubectl config use-context "$context"
          echo "✓ Kubernetes context set to: $context"
        fi
      };

      # Custom cd function
      function cd() {
        # Handle "cd" (no args)
        if [[ $# -eq 0 ]]; then
          builtin cd ~ || return
          return
        fi

        # Handle "cd -" (previous directory)
        if [[ "$1" == "-" ]]; then
          builtin cd - || return
          return
        fi

        # Handle normal case or path to file
        if [[ -d "$1" ]]; then
          builtin cd "$@" || return
        else
          local dir
          dir="$(dirname "$1")"
          builtin cd "$dir" || return
        fi
      }

      function ripvim() {
        rg --hidden --pcre2 --vimgrep "$@" | nvim -q - -c copen
      }

      __wezterm_set_user_var() {
        printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
      }

      precmd() {
        __wezterm_set_user_var WEZTERM_LAST_EXIT_STATUS $?
      }

      # Keybindings
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search

      function nix-shell () {
        nix-your-shell zsh nix-shell -- "$@"
      }

      function nix () {
        nix-your-shell zsh nix -- "$@"
      }

      set -o vi

      # Bind Ctrl+R to fzf history AFTER vi mode is set (vi mode clobbers it)
      bindkey -M viins '^R' fzf-history-widget
      bindkey -M vicmd '^R' fzf-history-widget

      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

      bindkey "^[[A" up-line-or-search     # Up arrow
      bindkey '^I' expand-or-complete      # Tab completion

      # Vicmd edit line with 'v'
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line

      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down


      kctx-widget() {
          kctx
          sleep 0.5
          zle reset-prompt
      }

      zle -N kctx-widget
      bindkey '^K' kctx-widget

      awsp-widget() {
          awsp
          sleep 0.5
          zle reset-prompt
      }
      zle -N awsp-widget
      bindkey '^P' awsp-widget

      motd
    '';

    plugins = [
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];
  };
}
