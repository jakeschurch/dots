{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  fix-hypr-resume = pkgs.writeShellScriptBin "fix-hypr-resume" ''
    sleep 2
    hyprctl dispatch dpms on
  '';
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

  # 2. Resume hook for NVIDIA DPMS fix
  systemd.services.hypr-resume-fix = {
    description = "Fix Hyprland DPMS after resume";
    after = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = fix-hypr-resume;
    };
    wantedBy = [ "suspend.target" ];
  };

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

      plugins = with pkgs.hyprlandPlugins; [
        hypr-dynamic-cursors
        hyprbars
        hyprwinwrap
        hyprexpo
        inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
      ];

      settings = {
        exec-once = [
          "systemctl --user enable --now hyprsunset.service"
          "uwsm app -- hyprpanel"
          # "wl-starfield"
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
              limit = 0.0;
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
        bind = , p, exec, systemctl poweroff  # Power off (Shutdown)
        bind = , r, exec, systemctl reboot   # Reboot
        bind = , s, exec, systemctl suspend-then-hibernate  # Power off (suspend) or could also be hibernate
        bind = , Return,submap,reset
        bind = , escape,submap,reset
        submap=reset
      '';
    };
  };

  environment = {
    systemPackages = with pkgs; [
      fix-hypr-resume
      tuigreet
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      wl-clipboard-rs
      hyprpanel
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
            backspace = "C-S-backspace";
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
