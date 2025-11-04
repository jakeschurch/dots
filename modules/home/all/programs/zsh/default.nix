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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
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
    initExtraBeforeCompInit = ''
      export ZSH_COMPDUMP=~/.zcompdump
      fpath+=(
        ~/.cache/zsh/completions
        "${config.home.profileDirectory}/share/zsh/site-functions"
      )
    '';
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
      if [[ -f ~/.zcompdump && -z ~/.zcompdump(#qN.mh+24) ]]; then
        compinit -i -C
      else
        compinit -i
      fi
    '';
    initExtra = ''
      # Custom cd function
      function cd() {
        if [[ -d "$1" ]]; then
          builtin cd "$@" || return
        else
          builtin cd "$(dirname "$1")" || return
        fi
      }

      if [[ -n "$ZSH_DEBUGRC" ]]; then
        zmodload zsh/zprof
        zprof
      fi

      # Keybindings
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
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

      # Autopair from zplug
      autopair-init

      # Lazy-load nix-shell and nix functions
      function nix-shell () {
        nix-your-shell zsh nix-shell -- "$@"
      }

      function nix () {
        nix-your-shell zsh nix -- "$@"
      }

      # Lazy-load Oh-My-Zsh plugins (if not already loaded)
      if [[ -z "$OMZ_LOADED" ]]; then
        source $ZSH/oh-my-zsh.sh
        export OMZ_LOADED=1
      fi

      # Lazy-load zplug plugins
      if [[ -z "$ZPLUG_LOADED" ]]; then
        # source ~/.zplug/init.zsh
        zplug load
        export ZPLUG_LOADED=1
      fi

      set -o vi
      motd
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "hlissner/zsh-autopair"; }
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "fzf"
        "gh"
        "git"
        "gnu-utils"
        "golang"
        "history-substring-search"
        "kubectl"
        "pip"
        "postgres"
        "pre-commit"
        "procs"
        "safe-paste"
        "terraform"
        "vi-mode"
      ];
    };
  };
}
