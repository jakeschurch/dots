{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jankyborders
  ];

  programs.aerospace = {
    enable = true;
    launchd.enable = false;

    userSettings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      exec.inherit-env-vars = true;

      after-startup-command = [
        "exec-and-forget ${pkgs.jankyborders}/bin/borders style=round hidpi=on inactive_color=0x000000 active_color=0xcc8ec07c width=32.0"
      ];

      start-at-login = true;

      # Mouse follows focus when focused monitor changes
      on-focused-monitor-changed = [ "move-mouse window-lazy-center" ];
      default-root-container-layout = "tiles";

      gaps = {
        inner = {
          horizontal = 48;
          vertical = 48;
        };
        outer = {
          left = 24;
          bottom = 24;
          top = 24;
          right = 24;
        };
      };

      workspace-to-monitor-force-assignment = {
        "1" = "^built-in retina display$";
        "s" = "^built-in retina display$";

        "2" = "secondary";
        "3" = "secondary";
        "4" = "secondary";
        "5" = "secondary";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
      };

      mode = {
        main = {
          binding = {
            # See: https://nikitabobko.github.io/AeroSpace/goodies#open-a-new-window-with-applescript

            # i3 wraps focus by default
            cmd-h = "focus --boundaries all-monitors-outer-frame --ignore-floating left";
            cmd-j = "focus --boundaries all-monitors-outer-frame --ignore-floating down";
            cmd-k = "focus --boundaries all-monitors-outer-frame --ignore-floating up";
            cmd-l = "focus --boundaries all-monitors-outer-frame --ignore-floating right";

            cmd-q = "close --quit-if-last-window";

            cmd-equal = "balance-sizes";
            cmd-minus = "flatten-workspace-tree";

            cmd-shift-h = "move left --boundaries all-monitors-outer-frame";
            cmd-shift-j = "move down --boundaries all-monitors-outer-frame";
            cmd-shift-k = "move up --boundaries all-monitors-outer-frame";
            cmd-shift-l = "move right --boundaries all-monitors-outer-frame";

            # apps
            cmd-enter = "exec-and-forget osascript -e 'tell application \"WezTerm\" to activate'";
            cmd-shift-enter = "exec-and-forget open -na Wezterm ";
            cmd-o = "exec-and-forget osascript -e 'tell application \"Google Chrome\" to activate'";
            cmd-shift-o = "exec-and-forget open -na \"Google Chrome\"";
            cmd-z = "exec-and-forget osascript -e 'tell application \"zoom.us\" to activate'";
            cmd-m = "exec-and-forget osascript -e 'tell application \"spotify\" to activate'";

            # Consider using 'join-with' command as a 'split' replacement if you want to enable normalizations
            cmd-f = "fullscreen";

            cmd-e = "swap up --wrap-around --swap-focus";

            # Not supported, because this command is redundant in AeroSpace mental model.
            # See: https://nikitabobko.github.io/AeroSpace/guide#floating-windows
            cmd-shift-space = "layout floating tiling";

            # `focus parent`/`focus child` are not yet supported, and it's not clear whether they should be supported at all
            # cmd-a = "focus parent";

            cmd-1 = "workspace 1";
            cmd-2 = "workspace 2";
            cmd-3 = "workspace 3";
            cmd-4 = "workspace 4";
            cmd-5 = "workspace 5";
            cmd-6 = "workspace 6";
            cmd-7 = "workspace 7";
            cmd-8 = "workspace 8";
            cmd-9 = "workspace 9";
            cmd-s = [
              "workspace s"
              "exec-and-forget osascript -e 'tell application \"Slack\" to activate'"
            ];

            cmd-shift-1 = [
              "move-node-to-workspace 1"
              "workspace 1"
            ];
            cmd-shift-2 = [
              "move-node-to-workspace 2"
              "workspace 2"
            ];
            cmd-shift-3 = [
              "move-node-to-workspace 3"
              "workspace 3"
            ];
            cmd-shift-4 = [
              "move-node-to-workspace 4"
              "workspace 4"
            ];
            cmd-shift-5 = [
              "move-node-to-workspace 5"
              "workspace 5"
            ];
            cmd-shift-6 = [
              "move-node-to-workspace 6"
              "workspace 6"
            ];
            cmd-shift-7 = [
              "move-node-to-workspace 7"
              "workspace 7"
            ];
            cmd-shift-8 = [
              "move-node-to-workspace 8"
              "workspace 8"
            ];
            cmd-shift-9 = [
              "move-node-to-workspace 9"
              "workspace 9"
            ];

            cmd-shift-r = "reload-config";

            cmd-r = "mode resize";
            cmd-p = "mode powermenu";
          };
        };

        resize = {
          binding = {
            h = "resize width -150";
            j = "resize height -150";
            k = "resize height +150";
            l = "resize width +150";
            enter = "mode main";
            esc = "mode main";
          };
        };

        powermenu = {
          binding = {
            l = [
              # locks screen
              "exec-and-forget open -a ScreenSaverEngine"
              "mode main"
            ];
            r = [
              "exec-and-forget sudo shutdown -r now"
              "mode main"
            ];
            s = [
              "exec-and-forget pmset sleepnow"
              "mode main"
            ];
            p = [
              "exec-and-forget sudo shutdown -h now"
              "mode main"
            ];
            esc = "mode main";
            enter = "mode main";
          };
        };
      };
    };
  };

}
