{
  lib,
  flake,
  pkgs,
  config,
  ...
}:
{
  options = {
    hyprland = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = {
    wayland.windowManager.hyprland = {
      inherit (config.hyprland) enable;

      plugins = [
        flake.inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
        flake.inputs.hy3.packages.${pkgs.system}.hy3
      ];

      settings = {
        plugin = [
          "hyprbars"
          "dynamic-cursors"
          "hy3"
        ];

        hy3 = {
          # Hy3 plugin options
          no_gaps_when_only = 1; # hide gaps if only one window
          node_collapse_policy = 2; # keep nested group only if parent is a tab group
          group_inset = 10; # offset when only one window in group

          # gaps and border
          gaps_in = 24;
          gaps_out = 8;
          border_size = 8;
          rounded_gaps = true;

          # tab bar (optional)
          tabs = {
            height = 22;
            padding = 6;
            from_top = false;
            radius = 6;
            border_width = 2;
            render_text = true;
            text_center = true;
            text_font = "JetBrains Mono";
            text_height = 8;
            text_padding = 3;
            blur = true;
            opacity = 1.0;
          };
        };

        # Keybindings (from your i3 config)
        bind = [
          # Focus
          "SUPER, H, hy3:movefocus left"
          "SUPER, J, hy3:movefocus down"
          "SUPER, K, hy3:movefocus up"
          "SUPER, L, hy3:movefocus right"

          # Move windows
          "SUPER SHIFT, H, hy3:movewindow left"
          "SUPER SHIFT, J, hy3:movewindow down"
          "SUPER SHIFT, K, hy3:movewindow up"
          "SUPER SHIFT, L, hy3:movewindow right"

          # Splits / make groups
          "SUPER SHIFT, V, hy3:makegroup v"
          "SUPER SHIFT, B, hy3:makegroup h"

          # Fullscreen
          "SUPER, F, hy3:fullscreen toggle"

          # Layout change
          "SUPER, S, hy3:layout stacking"
          "SUPER, W, hy3:layout tabbed"
          "SUPER, E, hy3:layout toggle"

          # Resize bindings (like i3 resize mode)
          # Grow / shrink width
          "SUPER CTRL, H, hy3:resize shrink width 10"
          "SUPER CTRL, L, hy3:resize grow width 10"

          # Grow / shrink height
          "SUPER CTRL, K, hy3:resize grow height 10"
          "SUPER CTRL, J, hy3:resize shrink height 10"

          # Switch to workspace
          "SUPER, 1, hy3:movetoworkspace 1"
          "SUPER, 2, hy3:movetoworkspace 2"
          "SUPER, 3, hy3:movetoworkspace 3"
          "SUPER, 4, hy3:movetoworkspace 4"
          "SUPER, 5, hy3:movetoworkspace 5"
          "SUPER, 6, hy3:movetoworkspace 6"
          "SUPER, 7, hy3:movetoworkspace 7"
          "SUPER, 8, hy3:movetoworkspace 8"
          "SUPER, 9, hy3:movetoworkspace 9"
          "SUPER, 0, hy3:movetoworkspace 0"

          # Move focused window to workspace
          "SUPER SHIFT, 1, hy3:moveworkspace 1 follow"
          "SUPER SHIFT, 2, hy3:moveworkspace 2 follow"
          "SUPER SHIFT, 3, hy3:moveworkspace 3 follow"
          "SUPER SHIFT, 4, hy3:moveworkspace 4 follow"
          "SUPER SHIFT, 5, hy3:moveworkspace 5 follow"
          "SUPER SHIFT, 6, hy3:moveworkspace 6 follow"
          "SUPER SHIFT, 7, hy3:moveworkspace 7 follow"
          "SUPER SHIFT, 8, hy3:moveworkspace 8 follow"
          "SUPER SHIFT, 9, hy3:moveworkspace 9 follow"
          "SUPER SHIFT, 0, hy3:moveworkspace 0 follow"
        ];

        dynamic-cursors = {
          enabled = true;

          # only tilt mode
          mode = "tilt";

          threshold = 2;

          # tilt-specific settings
          tilt = {
            limit = 5000;
            function = "negative_quadratic";
            window = 100;
          };

          # shake settings
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
          bar_height = 20;

          # buttons: color, size, icon, command
          hyprbars_button = [
            "rgb(ff4040), 10, 󰖭, hyprctl dispatch killactive"
            "rgb(eeee11), 10, , hyprctl dispatch fullscreen 1"
          ];

          # double-click command
          on_double_click = "hyprctl dispatch fullscreen 1";
        };
      };
    };
  };
}
