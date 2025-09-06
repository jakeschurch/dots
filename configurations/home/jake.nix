{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with pkgs.hyprlandPlugins; [
      hypr-dynamic-cursors
      hyprbars
    ];

    settings = {
      # mouse movements
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      input = {
        kb_layout = "us";
        numlock_by_default = true;
        repeat_delay = 300;
        follow_mouse = 0;
        float_switch_override_focus = 0;
        mouse_refocus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      "$mod" = "SUPER";

      general = {
        layout = "dwindle";
        gaps_in = 3;
        gaps_out = 10;
        float_gaps = 5;
        border_size = 5;
        resize_on_border = true;
      };

      decoration = {
        rounding = 10;
        dim_inactive = true;
      };

      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.7, 0.2, 0.3, 1.0"
        ];
        animation = [
          "windows, 3, 5, myBezier, slide"
          "windowsOut, 3, 5, myBezier, slide"
          "border, 2, 5, default"
          "fade, 2, 5, default"
          "workspaces, 2, 5, default"
        ];
      };

      plugin = {
        dynamic-cursors = {
          enabled = true;
          mode = "tilt";
          threshold = 2;
          tilt = {
            limit = 5000;
            function = "negative_quadratic";
            window = 100;
          };
          shake = {
            enabled = true;
            nearest = true;
            threshold = 6.0;
            base = 4.0;
            speed = 4.0;
            influence = 0.0;
            limit = 0.0;
            timeout = 2000;
            effects = false;
            ipc = false;
          };
        };

        # TODO: optional: use hyprcursor for high-res when magnified
        # hyprcursor = {
        #   nearest = true;
        #   enabled = true;
        #   resolution = -1;
        #   fallback = "clientside";
        # };

        # plugin-specific settings
        hyprbars = {
          enabled = true;
          bar_height = 30;
          bar_text_align = "left";
          bar_buttons_alignment = "left";
          bar_title_enabled = false;
          bar_blur = true;

          # buttons: color, size, icon, command
          hyprbars-button = [
            "rgb(ff4040), 15, , hyprctl dispatch killactive"
            "rgb(eeee11), 15, , hyprctl dispatch fullscreen 1"
          ];

          # double-click command
          on_double_click = "hyprctl dispatch fullscreen 1";
        };
      };

      # Keybindings (from your i3 config)
      bind = [
        "$mod, return, exec, wezterm"

        # Focus
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # hy3:Move windows
        "$mod+SHIFT, h, movewindow, l"
        "$mod+SHIFT, j, movewindow, d"
        "$mod+SHIFT, k, movewindow, u"
        "$mod+SHIFT, l, movewindow, r"

        # # Make groups / splits
        # "SUPER D, hy3:makegroup, h"
        # "SUPER S, hy3:makegroup, v"
        # "SUPER Z, hy3:makegroup, tab"

        # # Focus / lock / expand
        # "SUPER A, hy3:changefocus, raise"
        # "SUPER SHIFT, A, hy3:changefocus lower"
        # "SUPER X, hy3:locktab"
        # "SUPER E, hy3:expand, expand"
        # "SUPER SHIFT, E, hy3:expand base"
        # "SUPER R, hy3:changegroup, opposite"
        # "SUPER TAB, hy3:togglefocuslayer"

        # # Fullscreen
        # "SUPER, F, fullscreen, 1"
        # "SUPER SHIFT, F, fullscreen, 0"

        # # Workspace switching
        # "SUPER, 1, workspace, 01"
        # "SUPER, 2, workspace, 02"
        # "SUPER, 3, workspace, 03"
        # "SUPER, 4, workspace, 04"
        # "SUPER, 5, workspace, 05"
        # "SUPER, 6, workspace, 06"
        # "SUPER, 7, workspace, 07"
        # "SUPER, 8, workspace, 08"
        # "SUPER, 9, workspace, 09"
        # "SUPER, 0, workspace, 10"

        # # Move focused window to workspace
        # "SUPER SHIFT, 1, hy3:movetoworkspace 01"
        # "SUPER SHIFT, 2, hy3:movetoworkspace 02"
        # "SUPER SHIFT, 3, hy3:movetoworkspace 03"
        # "SUPER SHIFT, 4, hy3:movetoworkspace 04"
        # "SUPER SHIFT, 5, hy3:movetoworkspace 05"
        # "SUPER SHIFT, 6, hy3:movetoworkspace 06"
        # "SUPER SHIFT, 7, hy3:movetoworkspace 07"
        # "SUPER SHIFT, 8, hy3:movetoworkspace 08"
        # "SUPER SHIFT, 9, hy3:movetoworkspace 09"
        # "SUPER SHIFT, 0, hy3:movetoworkspace 10"
      ];
    };
  };
}
