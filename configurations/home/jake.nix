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
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;

    plugins = [
      flake.inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
      flake.inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      flake.inputs.hy3.packages.${pkgs.system}.hy3
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
        layout = "hy3"; # enables Hy3 tiling engine

        gaps_in = 3;
        gaps_out = 5;
        border_size = 1;
        col.active_border = "rgba(33ccffee)";
        col.inactive_border = "rgba(595959aa)";
        resize_on_border = true;
      };

      plugin = {
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

      # Keybindings (from your i3 config)
      bind = [
        "$mod, return, exec, wezterm"

        # Focus
        "$mod, h, hy3:movefocus, l"
        "$mod, j, hy3:movefocus, d"
        "$mod, k, hy3:movefocus, u"
        "$mod, l, hy3:movefocus, r"

        # hy3:Move windows
        "$mod+SHIFT, h, hy3:movewindow, l, once"
        "$mod+SHIFT, j, hy3:movewindow, d, once"
        "$mod+SHIFT, k, hy3:movewindow, u, once"
        "$mod+SHIFT, l, hy3:movewindow, r, once"

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
