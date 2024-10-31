_: {
  home = {
    file = {
      ".inputrc".text = ''
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

      '';

      ".pylintrc".text = ''
        [LOGGING]
        logging-format-style=new
        disable=W1203

        [FORMAT]
        max-line-length=110
      '';

      ".editrc".text = ''
        bind -v
      '';

      ".Xresources".text = ''
        Xft.dpi: 144
      '';

      ".psqlrc".source = ./rc/psqlrc;

      ".ripgreprc".text = ''
        --max-columns=150
        --max-columns-preview
        --glob=!{git,node_modules,dist}/*
        --smart-case
      '';
    };

    activation.psql-setup = ''
      [ -d ~/.cache/psql-history ] || mkdir -p ~/.cache/psql-history
    '';
  };

  xdg.configFile.".yamllint".text = ''
    # yaml
    extends: default

    rules:
      braces: enable
      brackets: enable
      colons: enable
      commas: enable
      comments: disable
      comments-indentation: disable
      document-end: disable
      document-start:
        level: warning
      empty-lines: enable
      empty-values: disable
      float-values: disable
      hyphens: enable
      indentation: enable
      key-duplicates: enable
      key-ordering: disable
      line-length: disable
      new-line-at-end-of-file: enable
      new-lines: enable
      octal-values: disable
      quoted-strings: disable
      trailing-spaces: enable
      truthy:
        level: warning
  '';
}
