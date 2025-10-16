{
  pkgs,
  lib,
  ...
}:
lib.mkIf (pkgs.system == "x86_64-linux") {
  services.dunst = {
    enable = false;
    /*
      REVIEW: iconTheme = {
        name = "gnome";
        size = "32x32";

      };
    */
    settings = {
      global = {
        monitor = 0;

        follow = "keyboard";
        shrink = "true";
        transparency = "0";
        separator_height = "2";
        frame_width = "1";
        corner_radius = "0";
        padding = "20";
        horizontal_padding = "10";

        # notification_height = "100";
        # startup_notification = "false";
        width = "300";
        height = "100";
        origin = "bottom-center";
        notification_limit = "5";

        show_age_threshold = "30";

        font = "Hack Regular Nerd Font Complete 10";

        line_height = "2";
        markup = "full";

        # The format of the message.  Possible variables are:
        #   %a  appname
        #   %s  summary
        #   %b  body
        #   %i  iconname (including its path)
        #   %I  iconname (without its path)
        #   %p  progress value if set ([  0%] to [100%]) or nothing
        #   %n  progress value if set without any extra characters
        #   %%  Literal %
        # Markup is allowed
        format = "%a: %s\n\n %b";

        # Alignment of message text.
        # Possible values are "left", "center" and "right".
        alignment = "left";

        word_wrap = "yes";

        # When word_wrap is set to no, specify where to make an ellipsis in long lines.
        # Possible values are "start", "middle" and "end".
        ellipsize = "middle";

        # Ignore newlines '\n' in notifications.
        ignore_newline = "no";

        # Stack together notifications with the same content
        stack_duplicates = true;

        # Hide the count of stacked notifications with the same content
        hide_duplicate_count = false;

        # Display indicators for URLs (U) and actions (A).
        show_indicators = "yes";

        ### Icons ###

        # Align icons left/right/off
        icon_position = "left";

        # Scale small icons up to this size, set to 0 to disable. Helpful
        # for e.g. small files or high-dpi screens. In case of conflict,
        # max_icon_size takes precedence over this.
        min_icon_size = 0;

        # Scale larger icons down to this size, set to 0 to disable
        max_icon_size = 32;

        # Paths to default icons.

        ### History ###

        # Should a notification popped up from history be sticky or timeout
        # as if it would normally do.
        sticky_history = false;

        # Maximum amount of notifications kept in history
        history_length = 5;

        ### Misc/Advanced ###

        /*
          # dmenu path.

          # Browser for opening urls in context menu.
          browser = /usr/bin/google-chrome-stable -new-tab

          # Always run rule-defined scripts, even if the notification is suppressed
          always_run_script = true

          # Define the title of the windows spawned by dunst
          title = Dunst

          # Define the class of the windows spawned by dunst
          class = Dunst
        */
      };

      colors = {
        background = "#32302f";
        foreground = "#ebdbb2";
      };
    };
  };
}
