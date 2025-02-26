{
  pkgs,
  lib,
  config,
  ...
}:
let
  zsh-completions = pkgs.callPackage ./zsh-completions.nix {
    packages = with pkgs; [ colima ];
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

          bindkey "^[[A" up-line-or-search     # Up arrow
          bindkey '^I' expand-or-complete      # Tab completion

          # Vicmd edit line with 'v'
          autoload -z edit-command-line
          zle -N edit-command-line
          bindkey -M vicmd v edit-command-line

          # Autopair from zplug
          autopair-init

          # Lazy-load Oh-My-Zsh plugins (if not already loaded)
          if [[ -z "$OMZ_LOADED" ]]; then
            source $ZSH/oh-my-zsh.sh
            export OMZ_LOADED=1
          fi

          # Lazy-load zplug plugins
          if [[ -z "$ZPLUG_LOADED" ]]; then
            source ~/.zplug/init.zsh
            zplug load
            export ZPLUG_LOADED=1
          fi

        '';
      };
    };
in
{
  home.file = homeFileReferences;

  programs.zsh = {
    enable = true;
    defaultKeymap = "vicmd";
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
      export AWS_PROFILE="fg-staging"
      export AWS_REGION="us-west-2"
      export PG_VERSION="15"
    '';
    initExtra = ''
      autoload -Uz compinit
      if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
        compinit -i -C
      else
        compinit -i
      fi

      # Custom cd function
      function cd() {
        # Check if the argument is a file (not a directory)
        if [[ -f "$1" ]]; then
          # If it's a file, change to its directory
          builtin cd "$(dirname "$1")" || return
        else
          # Otherwise, call the original cd command
          builtin cd "$@" || return
        fi
      }

       # MOTD (Message of the Day)
      if [[ ! -f ~/.motd_cache || $(\find ~/.motd_cache -mtime +1) ]]; then
        motd > ~/.motd_cache
      fi
      \cat ~/.motd_cache

      # Lazy-load functions and plugins
      zsh-defer source ~/.zshrc_lazy
    '';
    zplug = {
      enable = true;
      plugins = [
        { name = "hlissner/zsh-autopair"; }
        { name = "ptavares/zsh-direnv"; }
        { name = "romkatv/zsh-defer"; }
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
      ];
    };
  };
}
