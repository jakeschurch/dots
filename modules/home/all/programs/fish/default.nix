{
  config,
  lib,
  pkgs,
  ...
}:
let
  fish-completions = import ./fish-completions.nix {
    inherit pkgs lib;
    packages = with pkgs; [
      colima
    ];
  };

  homeFileReferences =
    builtins.listToAttrs (
      map (completion: {
        name = ".config/fish/completions/${completion.pname}.fish";
        value = {
          source = "${completion}/${completion.pname}.fish";
        };
      }) fish-completions
    )
    // {
      ".config/fish/completions/command-not-found.fish" = {
        source = "${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
      };
    };
in
{
  home.file = homeFileReferences;

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;

    shellAbbrs = {
      # Add any abbreviations you want here
    };

    shellAliases = {
      # Add any aliases you want here
    };

    shellInit = ''
      # Set environment variables
      set -gx AWS_PROFILE "fg-sso-staging-administrator-access"
      set -gx PG_VERSION "15"

      # Vi mode
      set -g fish_key_bindings fish_vi_key_bindings

      # Disable greeting
      set fish_greeting
    '';

    interactiveShellInit = ''
      # Calculator function
      function calc
        python3 -c "print(eval('$argv'))"
      end

      # AWS Profile Switcher with fzf
      function awsp
        set -l sso_profiles (grep -E '^\[profile ' ~/.aws/config | sed 's/^\[profile \(.*\)\]/\1/')
        set -l cred_profiles (grep -E '^\[profile ' ~/.aws/credentials | sed 's/^\[profile \(.*\)\]/\1/')

        set -l profile_selections (printf "%s\n%s" $sso_profiles $cred_profiles | sort -u)
        set -l profile (printf "%s" $profile_selections | fzf --height 40% --prompt="AWS Profile> ")

        if test -n "$profile"
          set -gx AWS_PROFILE "$profile"
          echo "✓ AWS_PROFILE set to: $profile"
        end
      end

      # Kubernetes Context Switcher with fzf
      function kctx
        set -l context (kubectl config get-contexts -o name | fzf --height 40% --reverse --prompt="K8s Context> ")

        if test -n "$context"
          kubectl config use-context "$context"
          echo "✓ Kubernetes context set to: $context"
        end
      end

      # Custom cd function (fish already handles cd to files well, but keeping for consistency)
      function cd
        if test (count $argv) -eq 0
          builtin cd ~
        else if test "$argv[1]" = "-"
          builtin cd -
        else if test -d "$argv[1]"
          builtin cd $argv
        else
          # If it's a file, cd to its directory
          set -l dir (dirname "$argv[1]")
          builtin cd "$dir"
        end
      end

      # Ripgrep + Neovim
      function ripvim
        rg --hidden --pcre2 --vimgrep $argv | nvim -q - -c copen
      end

      # WezTerm integration
      function __wezterm_set_user_var
        printf "\033]1337;SetUserVar=%s=%s\007" $argv[1] (echo -n $argv[2] | base64)
      end

      # Hook to run after each command
      function __fish_postexec --on-event fish_postexec
        __wezterm_set_user_var WEZTERM_LAST_EXIT_STATUS $status
      end

      # Nix-your-shell integration
      function nix-shell
        nix-your-shell fish nix-shell -- $argv
      end

      function nix
        nix-your-shell fish nix -- $argv
      end

      # Keybindings for vi mode
      # Ctrl+R for fzf history search (fzf.fish plugin provides this)
      bind -M insert \cr __fzf_search_history
      bind -M default \cr __fzf_search_history

      # Ctrl+K for kubernetes context switcher
      bind -M insert \ck 'kctx; commandline -f repaint'
      bind -M default \ck 'kctx; commandline -f repaint'

      # Ctrl+P for AWS profile switcher
      bind -M insert \cp 'awsp; commandline -f repaint'
      bind -M default \cp 'awsp; commandline -f repaint'

      # Run motd
      motd
    '';

    plugins = [
      # fzf.fish - fzf integration
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.3";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
      # autopair.fish - auto-pair brackets, quotes, etc.
      {
        name = "autopair.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
    ];
  };
}
