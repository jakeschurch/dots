{
  lib,
  pkgs,
  ...
}:
let
  colors = ''
    # gruvbox-nvim soft dark
    set -g fish_color_normal d4be98      # fg1
    set -g fish_color_command 98971a     # green (bright)
    set -g fish_color_keyword fb4934     # red (bright)
    set -g fish_color_quote d8a657       # yellow
    set -g fish_color_redirection 89b482 # aqua
    set -g fish_color_end d3869b         # purple
    set -g fish_color_error fb4934       # red (bright)
    set -g fish_color_param d4be98       # fg1
    set -g fish_color_comment 928374     # gray (medium)
    set -g fish_color_selection --background=514045  # soft dark bg2
    set -g fish_color_search_match --background=514045
    set -g fish_color_operator 89b482    # aqua
    set -g fish_color_escape d8a657      # yellow
    set -g fish_color_autosuggestion 928374  # gray
    set -g fish_color_cwd d8a657         # yellow
    set -g fish_color_user a9b665        # green
    set -g fish_color_host 89b482        # aqua
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_selected_background --background=514045
    set -g fish_pager_color_completion d4be98
    set -g fish_pager_color_description 928374
    set -g fish_pager_color_prefix brwhite --bold
  '';

  fish-completions = import ./fish-completions.nix {
    inherit pkgs lib;
    packages = with pkgs; [
      colima
    ];
  };

  homeFileReferences = builtins.listToAttrs (
    map (completion: {
      name = ".config/fish/completions/${completion.pname}.fish";
      value = {
        source = "${completion}/${completion.pname}.fish";
      };
    }) fish-completions
  );
in
{
  home.file = homeFileReferences;

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    generateCompletions = false;

    shellAbbrs = { };
    shellAliases = { };

    shellInit = ''
      ${colors}

      set -g fzf_history_time_format "%Y-%m-%d %H:%M"
      set -gx AWS_PROFILE "fg-sso-staging-administrator-access"
      set -gx PG_VERSION "15"
      set -g fish_key_bindings fish_vi_key_bindings
      bind vv edit_command_buffer

      set fish_greeting
      set -g fish_complete_path_insensitive 1 # Case insensitive completions
      set -g fish_history_size 100000 # Longer history
    '';

    interactiveShellInit = ''
      function calc
        python3 -c "print(eval('$argv'))"
      end

      function awsp
        set -l all_profiles (
          grep -E '^\[profile ' ~/.aws/config ~/.aws/credentials 2>/dev/null \
            | sed 's/.*\[profile \(.*\)\]/\1/' \
            | sort -u
        )
        set -l profile (printf "%s\n" $all_profiles | fzf --height 40% --prompt="AWS Profile> ")
        if test -n "$profile"
          set -gx AWS_PROFILE "$profile"
          echo "✓ AWS_PROFILE set to: $profile"
        end
      end

      function kctx
        set -l context (kubectl config get-contexts -o name | fzf --height 40% --reverse --prompt="K8s Context> ")
        if test -n "$context"
          kubectl config use-context "$context"
          echo "✓ Kubernetes context set to: $context"
        end
      end

      function ripvim
        rg --hidden --pcre2 --vimgrep $argv | nvim -q - -c copen
      end

      # Set explicit tab titles on shell events instead of formatting them in Lua.
      function __wezterm_set_tab_title
        test -n "$WEZTERM_PANE"; or return

        set -l title "$argv[1]"
        if set -q __wezterm_last_tab_title; and test "$title" = "$__wezterm_last_tab_title"
          return
        end

        # Bound the IPC wait so an unavailable GUI cannot hang the shell.
        if ${pkgs.coreutils}/bin/timeout 0.25s ${pkgs.wezterm}/bin/wezterm cli --no-auto-start set-tab-title --pane-id "$WEZTERM_PANE" -- "$title" >/dev/null 2>&1
          set -g __wezterm_last_tab_title "$title"
        end
      end

      function __wezterm_tab_preexec --on-event fish_preexec
        # An empty explicit title lets the foreground app supply its own title.
        __wezterm_set_tab_title ""
      end

      function __wezterm_tab_postexec --on-event fish_postexec
        set -l command_status $status
        set -l symbol ✔
        if test $command_status -ne 0
          set symbol ✖
        end
        __wezterm_set_tab_title "$symbol "(path basename -- "$PWD")
      end

      __wezterm_set_tab_title (path basename -- "$PWD")

      function nix-shell
        nix-your-shell fish nix-shell -- $argv
      end

      function nix
        nix-your-shell fish nix -- $argv
      end

      # Ctrl+R handled by fzf.fish plugin
      # Ctrl+K for kctx
      bind -M insert \ck 'kctx; commandline -f repaint'
      bind -M default \ck 'kctx; commandline -f repaint'

      # Ctrl+P for awsp
      bind -M insert \cp 'awsp; commandline -f repaint'
      bind -M default \cp 'awsp; commandline -f repaint'

      motd
    '';

    plugins = [
      {
        name = "fzf.fish";
        inherit (pkgs.fishPlugins.fzf-fish) src;
      }
      {
        name = "autopair.fish";
        inherit (pkgs.fishPlugins.autopair) src;
      }
    ];
  };

  home.packages = with pkgs; [
    nix-your-shell
  ];
}
