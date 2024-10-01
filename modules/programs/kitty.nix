{
  programs.kitty = {
    enable = true;
    theme = "Gruvbox Dark Soft";
    keybindings = {
      # window movements
      "kitty_mod+t" = "new_tab";
      "kitty_mod+n" = "next_tab";
      "kitty_mod+shift+n" = "previous_tab";
      "kitty_mod+shift+q" = "close_tab";

      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+j" = "neighboring_window down";
      "kitty_mod+k" = "neighboring_window up";
      "kitty_mod+l" = "neighboring_window right";

      "kitty_mod+shift+h" = "move_window left";
      "kitty_mod+shift+j" = "move_window down";
      "kitty_mod+shift+k" = "move_window up";
      "kitty_mod+shift+l" = "move_window right";

      "kitty_mod+e" = "kitten hints";

      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+c" = "copy_from_clipboard";
      "kitty_mod+enter" = "launch --location=hsplit --cwd=current";
      "kitty_mod+shift+enter" = "launch --location=vsplit --cwd=current";
      "kitty_mod+q" = "close_window";
      "kitty_mod+r" = "start_resizing_window";
      "kitty_mod+shift+f" = "toggle_fullscreen";
      "kitty_mod+f" = "toggle_maximized";

      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";

      "kitty_mod+p>f" = "kitten hints --type path --program -";

      "kitty_mod+p>shift+f" = "kitten hints --type path";

      "kitty_mod+p>l" = "kitten hints --type line --program -";

      # Select a line of text and insert it into the terminal. Use for the output of things like: ls -1;
      "kitty_mod+p>w" = "kitten hints --type word --program -";

      # Select words and insert into terminal.;
      "kitty_mod+p>h" = "kitten hints --type hash --program -";
    };
    extraConfig = ''
      font_family      JetBrains Mono Regular
      bold_font        JetBrains Mono Bold
      italic_font      JetBrains Mono Italic
      bold_italic_font JetBrains Mono Bold Italic

      open_url_with $BROWSER
      open_url_modifiers kitty_mod

      map kitty_mod+1 goto_tab 1
      map kitty_mod+2 goto_tab 2
      map kitty_mod+3 goto_tab 3
      map kitty_mod+4 goto_tab 4
      map kitty_mod+5 goto_tab 5
      map kitty_mod+6 goto_tab 6
      map kitty_mod+7 goto_tab 7
      map kitty_mod+8 goto_tab 8
      map kitty_mod+9 goto_tab 9
      map kitty_mod+0 goto_tab 10
    '';
    settings = {
      enabled_layouts = "splits:split_axis=horizontal";
      clear_all_shortcuts = "yes";
      font_size = "13.0";
      kitty_mod = "alt";

      # tabs
      active_tab_background = "#32302f";
      active_tab_font_style = "bold-italic";
      active_tab_foreground = "#ebdbb2";
      active_tab_title_template = "{title}";
      inactive_tab_background = "#32302f";
      inactive_tab_font_style = "normal";
      inactive_tab_foreground = "#a89984";
      tab_bar_edge = "bottom";
      tab_bar_min_tabs = 2;
      tab_bar_style = "powerline";
      tab_switch_strategy = "previous";
      tab_title_template = "{index}: {title}";

      # general
      active_border_color = "#d3869b";
      cursor_shape = "block";
      draw_minimal_borders = "yes";
      focus_follows_mouse = "yes";
      hide_window_decorations = "no";
      inactive_border_color = "#83c07c";
      remember_window_size = "no";
      single_window_margin_width = "-1";
      window_border_width = "8.0";
      window_margin_width = "0.38 1 0.38 1";
      window_padding_width = "5";

      adjust_line_height = 0;
      adjust_column_width = 0;

      close_on_child_death = "no";

      sync_to_monitor = "yes";
      visual_bell_duration = "0.0";
      clipboard_control = "write-clipboard read-clipboard";
      cursor_blink_interval = "0";

      allow_remote_control = "no";

      mouse_hide_wait = 0;
    };
  };
}
