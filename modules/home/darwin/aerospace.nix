{ lib, ... }:
let
  workspaceNames = (map toString (lib.lists.range 1 9)) ++ [ "s" ];
  WithBindingFallthrough =
    bindingAttrs:
    let
      alphaNumKeys = lib.strings.stringToCharacters "abcdefghijklmnopqrstuvwxyz1234567890";

      nonAlphaNumKeys = [
        # control
        "esc"
        "enter"
        "tab"
        "backspace"
        "space"
        "home"
        "end"

        # arrows
        "left"
        "right"
        "up"
        "down"

        # function
        "f1"
        "f2"
        "f3"
        "f4"
        "f5"
        "f6"
        "f7"
        "f8"
        "f9"
        "f10"
        "f11"
        "f12"
        "f13"
        "f14"
        "f15"
        "f16"
        "f17"
        "f18"
        "f19"
        "f20"

        # punctuation
        "minus"
        "equal"
        "backslash"
        "semicolon"
        "comma"
        "period"
        "slash"
      ];

      allKeys = alphaNumKeys ++ nonAlphaNumKeys;
      fallthroughKeys = lib.lists.subtractLists (builtins.attrNames bindingAttrs) allKeys;
    in
    bindingAttrs
    // (builtins.listToAttrs (
      map (key: {
        name = key;
        value = "mode main";
      }) fallthroughKeys
    ));
in
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    userSettings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      automatically-unhide-macos-hidden-apps = true;

      exec.inherit-env-vars = true;

      after-startup-command = [
        "exec-and-forget bitwarden-desktop"
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

      workspace-to-monitor-force-assignment = builtins.foldl' (
        acc: name:
        {
          "${name}" = if name == "1" || name == "s" then "^built-in retina display$" else "secondary";
        }
        // acc
      ) { } workspaceNames;

      mode =
        let
          WorkspaceSwitchingBindings = builtins.foldl' (
            acc: name:
            {
              "cmd-shift-${name}" = [
                "move-node-to-workspace ${name}"
                "workspace ${name}"
              ];
            }
            # cmd-s reserved for viewing slack
            // lib.optionalAttrs (name != "s") {
              "cmd-${name}" = "workspace ${name}";
            }
            // acc
          ) { } workspaceNames;
        in
        {
          main = {
            binding = WorkspaceSwitchingBindings // {
              # See: https://nikitabobko.github.io/AeroSpace/goodies#open-a-new-window-with-applescript

              # i3 wraps focus by default
              cmd-h = "focus --boundaries all-monitors-outer-frame --ignore-floating left";
              cmd-j = "focus --boundaries all-monitors-outer-frame --ignore-floating down";
              cmd-k = "focus --boundaries all-monitors-outer-frame --ignore-floating up";
              cmd-l = "focus --boundaries all-monitors-outer-frame --ignore-floating right";

              cmd-q = "close --quit-if-last-window";
              cmd-m = "macos-native-minimize";

              cmd-equal = "balance-sizes";
              cmd-minus = "flatten-workspace-tree";

              cmd-shift-h = "move left --boundaries all-monitors-outer-frame";
              cmd-shift-j = "move down --boundaries all-monitors-outer-frame";
              cmd-shift-k = "move up --boundaries all-monitors-outer-frame";
              cmd-shift-l = "move right --boundaries all-monitors-outer-frame";

              # apps
              cmd-enter = "exec-and-forget osascript -e 'tell application \"WezTerm\" to activate'";
              cmd-shift-enter = "exec-and-forget open -na Wezterm";
              cmd-shift-o = "exec-and-forget open -na Firefox";

              # Consider using 'join-with' command as a 'split' replacement if you want to enable normalizations
              cmd-f = "fullscreen";

              cmd-e = "swap up --wrap-around --swap-focus";

              # Not supported, because this command is redundant in AeroSpace mental model.
              # See: https://nikitabobko.github.io/AeroSpace/guide#floating-windows
              cmd-shift-space = "layout floating tiling";

              # `focus parent`/`focus child` are not yet supported, and it's not clear whether they should be supported at all
              # cmd-a = "focus parent";

              cmd-s = [
                "workspace s"
                "exec-and-forget osascript -e 'tell application \"Slack\" to activate'"
              ];

              cmd-shift-r = "reload-config";

              cmd-r = "mode resize";
              cmd-p = "mode powermenu";

              cmd-o = "mode app";
            };
          };

          app = {
            binding =
              let
                mkActivationBinding = app: [
                  "exec-and-forget osascript -e 'tell application \"${app}\" to activate'"
                  "mode main"
                ];
              in
              builtins.mapAttrs (_name: mkActivationBinding) {
                enter = "Wezterm";
                o = "Google Chrome";
                z = "zoom.us";
                n = "Notion";
                comma = "Notion Calendar";
                m = "spotify";
              };
          };

          resize = {
            binding = WithBindingFallthrough {
              h = "resize width -150";
              j = "resize height -150";
              k = "resize height +150";
              l = "resize width +150";
            };
          };

          powermenu = {
            binding =
              let
                mkPowerBinding = action: [
                  "exec-and-forget ${action}"
                  "mode main"
                ];
              in
              WithBindingFallthrough (
                builtins.mapAttrs (_name: mkPowerBinding) {
                  r = "sudo shutdown -r now"; # restart
                  s = "pmset sleepnow"; # sleep
                  p = "sudo shutdown -h now"; # power off
                  l = "open -a ScreenSaverEngine"; # lock screen
                }
              );
          };
        };
    };
  };

}
