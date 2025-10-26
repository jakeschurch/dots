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
    ./configuration.nix
    ./disko-config.nix
    self.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.hyprland.nixosModules.default
    inputs.walker.nixosModules.default
  ];

  environment = {
    systemPackages = with pkgs; [
      tuigreet
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      wl-clipboard-rs
      hyprpanel
    ];

    etc."greetd/environments".text = ''
      hyprland
      zsh
      bash
    '';

    variables.NIXOS_OZONE_WL = "1";
  };

  programs.walker = {
    enable = true;
    runAsService = true;
    package = pkgs.walker;

    config = {
      providers.prefixes = [
        {
          provider = "websearch";
          prefix = "?";
        }
        {
          provider = "switcher";
          prefix = "/";
        }
      ];
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    plugins = with pkgs.hyprlandPlugins; [
      hypr-dynamic-cursors
      hyprbars
      hyprspace
      # hyprexpo
      hyprwinwrap
    ];

    settings = {
      exec-once = [
        "systemctl --user enable --now hyprsunset.service"
        "uwsm app -- hyprpanel"
        # "uswsm app -- eww --debug --no-daemonize daemon"
        # "wl-starfield"
      ];

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
        follow_mouse = true;
        float_switch_override_focus = 0;
        mouse_refocus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      "$mod" = "SUPER";

      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
      ];

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
      };

      plugin = {
        hyprspace = {
          enable = true;
        };

        dynamic-cursors = {
          enabled = true;
          mode = "rotate";
          threshold = 2;
          rotate = {
            limit = 4000;
            function = "linear";
            window = 100;
          };
          shake = {
            enabled = true;
            nearest = true;
            threshold = 3.0;
            base = 1.5;
            speed = 3.0;
            influence = 0.0;
            limit = 0.0;
            timeout = 100;
            effects = false;
            ipc = false;
          };
        };

        hyprexpo = {

        };

        hyprcursor = {
          nearest = true;
          enabled = true;
          resolution = -1;
          fallback = "clientside";
        };

        # plugin-specific settings
        hyprbars = {
          enabled = true;
          bar_height = 40;
          bar_text_align = "left";
          bar_buttons_alignment = "left";
          bar_title_enabled = false;
          bar_part_of_window = false;
          bar_precedence_over_border = false;

          bar_blur = true;
          bar_padding = 12;
          bar_button_padding = 10;

          # buttons: color, size, icon, command
          hyprbars-button = [
            "rgb(ff5f56), 15, , hyprctl dispatch killactive" # Close (red)
            "rgb(ffbd2e), 15, , hyprctl dispatch minimizeactive" # Minimize (yellow)
            "rgb(27c93f), 15, , hyprctl dispatch fullscreen 1" # Maximize (green)
          ];

          # double-click command
          on_double_click = "hyprctl dispatch fullscreen 1";
        };
      };

      bind = [
        "$mod, c, exec, wl-copy"
        "$mod, v, exec, wl-paste"

        "$mod,space, exec, walker"

        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"

        "$mod,XF86MonBrightnessDown, exec, hyprctl hyprsunset temperature -250"
        "$mod,XF86MonBrightnessUp, exec, hyprctl hyprsunset temperature +250"

        ",XF86MonBrightnessDown, exec, hyprctl hyprsunset gamma -10"
        ",XF86MonBrightnessUp, exec, hyprctl hyprsunset gamma +10"

        # "$mod, up, hyprexpo:expo, toggle"

        "$mod, left, workspace, e-1"
        "$mod, right, workspace, e+1"

        # "ctrl, up, overview:toggle, all"

        "$mod, return, exec, wezterm"

        # Focus
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Move windows
        "$mod+SHIFT, h, movewindow, l"
        "$mod+SHIFT, j, movewindow, d"
        "$mod+SHIFT, k, movewindow, u"
        "$mod+SHIFT, l, movewindow, r"

        # reload
        "$mod+SHIFT, r, exec, hyperctl reload"

        # quit
        "$mod, Q, killactive"

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

        # Fullscreen
        "SUPER, F, fullscreen, 1"
        "SUPER SHIFT, F, fullscreen, 0"

        # Workspace switching
        "SUPER, 1, workspace, 01"
        "SUPER, 2, workspace, 02"
        "SUPER, 3, workspace, 03"
        "SUPER, 4, workspace, 04"
        "SUPER, 5, workspace, 05"
        "SUPER, 6, workspace, 06"
        "SUPER, 7, workspace, 07"
        "SUPER, 8, workspace, 08"
        "SUPER, 9, workspace, 09"
        "SUPER, 0, workspace, 10"

        # Move focused window to workspace
        "SUPER SHIFT, 1, movetoworkspacesilent, 01"
        "SUPER SHIFT, 2, movetoworkspacesilent, 02"
        "SUPER SHIFT, 3, movetoworkspacesilent, 03"
        "SUPER SHIFT, 4, movetoworkspacesilent, 04"
        "SUPER SHIFT, 5, movetoworkspacesilent, 05"
        "SUPER SHIFT, 6, movetoworkspacesilent, 06"
        "SUPER SHIFT, 7, movetoworkspacesilent, 07"
        "SUPER SHIFT, 8, movetoworkspacesilent, 08"
        "SUPER SHIFT, 9, movetoworkspacesilent, 09"
        "SUPER SHIFT, 0, movetoworkspacesilent, 10"
      ];
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd hyprland";
        user = "jake";
      };
    };
  };

}
