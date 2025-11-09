{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  withWorkspaces =
    keyset: cmd:
    let
      range = lib.lists.range 1 9;

      createWorkspaceCmd =
        i:
        lib.concatStringsSep ", " [
          keyset
          (builtins.toString i)
          cmd
          "0${builtins.toString i}"
        ];
    in
    builtins.map createWorkspaceCmd range;
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

  programs = {
    walker = {
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

    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;

      plugins =
        with inputs.hyprland-plugins.packages.${pkgs.system};
        [
          hyprbars
          hyprwinwrap
          hyprexpo
        ]
        ++ (with pkgs; [
          inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
          # inputs.hyprspace.packages.${pkgs.system}.Hyprspace
          hyprsunset
        ]);

      settings = {
        exec-once = [
          "systemctl --user enable --now hyprsunset.service"
          "systemctl --user enable --now hypridle.service"
          "uwsm app -- hyprpanel"
          # "uwsm app -- ${hypr-dynamic-aspect}/bin/hypr-dynamic-aspect"
        ];

        # mouse movements
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod ALT, mouse:272, resizewindow"
        ];

        misc = {
          force_default_wallpaper = 1;
          disable_hyprland_logo = true;
        };

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

        dwindle = {
          force_split = 2; # always split to right
          single_window_aspect_ratio = "4 3";
        };

        decoration = {
          rounding = 10;
          dim_inactive = true;
        };

        animations = {
          enabled = true;
        };

        plugin = {
          hyprexpo = {
            enabled = true;
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
              limit = 0.2; # REVIEW
              timeout = 100;
              effects = false;
              ipc = false;
            };
          };

          hyprcursor = {
            nearest = true;
            enabled = true;
            resolution = -1;
            fallback = "clientside";
          };

          hyprexpo = { };

          # plugin-specific settings
          hyprbars = {
            enabled = true;
            bar_height = 40;
            bar_text_align = "left";
            bar_buttons_alignment = "left";
            bar_title_enabled = false;
            bar_precedence_over_border = true;

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

          # NOTE: use ctrl due to keyd re-mappings
          # "ctrl, up, overview, toggle"
          "ctrl, left, workspace, e-1"
          "ctrl, right, workspace, e+1"

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
          "$mod+SHIFT, r, exec, hyperctl reload && notify-send 'hyprland reloaded 👍'"

          # quit
          "$mod, Q, killactive"

          # Fullscreen
          "SUPER, F, fullscreen, 0"
        ]
        ++
          # Move focused window to workspace
          (withWorkspaces "SUPER SHIFT" "movetoworkspacesilent")
        ++

          # Workspace switching
          (withWorkspaces "SUPER" "workspace");
      };

      extraConfig = ''
        misc:vfr = true

        bind = $mod, R,submap,resize
        submap=resize
        binde = , h, resizeactive, -40 0
        binde = , j, resizeactive, 0 40
        binde = , k, resizeactive, 0 -40
        binde = , l, resizeactive, 40 0
        binde = , Return,submap,reset
        binde = , escape,submap,reset
        submap=reset

        bind = $mod, P,submap,powermenu
        submap=powermenu
        bind = , l, exec, hyprlock --immediate # Lock screen
        bind = , l, submap, reset

        bind = , p, exec, systemctl poweroff  # Power off (Shutdown)
        bind = , p, submap, reset

        bind = , r, exec, systemctl reboot   # Reboot
        bind = , r, submap, reset

        bind = , s, exec, systemctl suspend-then-hibernate  # Power off (suspend) or could also be hibernate
        bind = , s, submap, reset

        bind = , Return,submap,reset
        bind = , escape,submap,reset
        submap=reset
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [
      hyprpanel
      tuigreet
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      wl-clipboard-rs
      libnotify
    ];

    etc."greetd/environments".text = ''
      hyprland
      zsh
      bash
    '';

    variables.NIXOS_OZONE_WL = "1";
  };

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          alt = {
            left = "C-left";
            right = "C-right";
            backspace = "C-backspace";
          };

          meta = {
            # These become Ctrl when Super is held
            backspace = "C-backspace";
            c = "C-c";
            v = "C-v";
            x = "C-x";
            a = "C-a";
            s = "C-s";
            z = "C-z";
            t = "C-t";
            w = "C-w";
            up = "C-home";
            down = "C-end";
            left = "home";
            right = "end";
          };
        };
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session =
        let
          tuigreetArgs = builtins.concatStringsSep " " [
            "--power-shutdown 'sudo systemctl poweroff'"
            "--time"
            "--asterisks"
            "--cmd hyprland"
          ];
        in
        {
          command = "${pkgs.tuigreet}/bin/tuigreet ${tuigreetArgs}";
          user = "jake";
        };
    };
  };
}
