{
  pkgs,
  callPackage,
  lib,
  config,
  ...
}:
let
  zsh-completions = callPackage ./zsh-completions.nix {
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

      ".zsh_lazy" = {
        text = ''
          # Keybindings
          autoload -U up-line-or-beginning-search
          autoload -U down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search

          # Autopair from zplug
          zsh-defer autopair-init

          # Lazy-load nix-shell and nix functions
          function nix-shell () {
            nix-your-shell zsh nix-shell -- "$@"
          }

          function nix () {
            nix-your-shell zsh nix -- "$@"
          }

          # Lazy-load Oh-My-Zsh plugins (if not already loaded)
          if [[ -z "$OMZ_LOADED" ]]; then
            zsh-defer source $ZSH/oh-my-zsh.sh
            export OMZ_LOADED=1
          fi

          # Lazy-load zplug plugins
          if [[ -z "$ZPLUG_LOADED" ]]; then
            zsh-defer source ~/.zplug/init.zsh
            zsh-defer zplug load
            export ZPLUG_LOADED=1
          fi
        '';
      };
    };
in
{
  home.file = homeFileReferences;

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
      export AWS_REGION="us-west-2"
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

      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      zvm_bindkey vicmd "^[[A" up-line-or-search     # Up arrow
      zvm_bindkey '^I' expand-or-complete      # Tab completion
      zvm_bindkey vicmd v edit-command-line
      zvm_bindkey vicmd 'k' history-substring-search-up
      zvm_bindkey vicmd 'j' history-substring-search-down

      ZVM_CURSOR_STYLE_ENABLED=false
      ZVM_VI_ESCAPE_BINDKEY=ESC

      # Vicmd edit line with 'v'
      autoload -z edit-command-line
      zle -N edit-command-line

      # Lazy-load functions and plugins
      zsh-defer source ~/.zsh_lazy
      motd
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "hlissner/zsh-autopair"; }
        { name = "romkatv/zsh-defer"; }
        { name = "jeffreytse/zsh-vi-mode"; }
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "fzf"
        "git"
        "history-substring-search"
      ];
    };
  };
}
