{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    plugins =
      with inputs.hyprland-plugins.packages.${pkgs.system};
      [
        # hyprbars
      ]
      ++ (with pkgs; [
        # inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
        hyprsunset
      ]);

    settings = {
      exec-once = [
        "uwsm app -- hyprsunset"
        "uwsm app -- hypridle"
        "uwsm app -- awww-daemon"
        "sleep 1 && awww img ~/Pictures/Wallpapers/animated --transition-type grow --transition-fps 60"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
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

      windowrule = [
        "monitor DP-1, fullscreen 3, match:class ^(steam_app_.*)$"
        "match:class ^(cliphist-picker)$, float on"
        "match:class ^(cliphist-picker)$, size 800 500"
        "match:class ^(cliphist-picker)$, float on, center on"
      ];

      env = [
        # Force Hyprland to only use NVIDIA GPU (card1), Intel B60 (card2) passed through to k3s-worker-4
        "AQ_DRM_DEVICES,/dev/dri/card1"

        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "WLR_NO_HARDWARE_CURSORS,1"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GL_GSYNC_ALLOWED,1"
        "__GL_VRR_ALLOWED,1"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      layout = {
        single_window_aspect_ratio = "4 3";
      };

      general = {
        layout = "dwindle";
        gaps_in = 3;
        gaps_out = 10;
        float_gaps = 5;
        border_size = 3;
        resize_on_border = true;
      };

      dwindle = {
        force_split = 2; # always split to right
        smart_split = false;
        smart_resizing = false;
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        dim_inactive = true;
      };

      animations = {
        enabled = true;
      };

      plugin = {
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
            threshold = 2.0;
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

        # plugin-specific settings
        hyprbars = {
          bar_height = 30;
          bar_title_enabled = false;
          bar_buttons_alignment = "right";
          bar_part_of_window = true;

          bar_blur = true;
          bar_padding = 12;
          bar_button_padding = 10;

          # # buttons: color, size, icon, command
          hyprbars-button = [
            "rgb(ff5f56), 15, , smart-kill" # Close (red)
            "rgb(ffbd2e), 15, , hyprctl dispatch movetoworkspacesilent special" # Minimize (yellow)
            "rgb(27c93f), 15, , hyprctl dispatch fullscreen 1" # Maximize (green)
          ];

          # double-click command
          on_double_click = "hyprctl dispatch fullscreen 1";
        };
      };

      bind =
        let
          workspaces = lib.lists.range 1 9;
          withWorkspaces = x: map x workspaces;

          mkCmd = lib.concatStringsSep ", ";

          mkCmdFromAttrs =
            bindPrefix: cmd: bindKey: value:
            mkCmd [
              bindPrefix
              bindKey
              cmd
              value
            ];

          mkWorkspaceCmd =
            modPrefix: cmd: workspace:
            let
              workspaceStr = toString workspace;
            in
            mkCmd [
              modPrefix
              workspaceStr
              cmd
              "0${workspaceStr}"
            ];

          # Move focused window to workspace
          mkFocusWorkspaceCmds = withWorkspaces (mkWorkspaceCmd "SUPER+SHIFT" "movetoworkspace");

          # Workspace switching
          mkSwitchWorkspaceCmds = withWorkspaces (mkWorkspaceCmd "SUPER" "workspace");

          mkMoveCmds =
            let
              mkFocusCmd = mkCmdFromAttrs "$mod" "movefocus";
              mkMoveCmd = mkCmdFromAttrs "$mod+shift" "movewindow";
              directions = {
                h = "l";
                j = "d";
                k = "u";
                l = "r";
              };
            in
            lib.flatten (
              lib.mapAttrsToList (key: value: [
                (mkFocusCmd key value)
                (mkMoveCmd key value)
              ]) directions
            );
        in
        mkFocusWorkspaceCmds
        ++ mkSwitchWorkspaceCmds
        ++ mkMoveCmds
        ++ [
          "$mod,space, exec, noctalia-shell ipc call launcher toggle"

          ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioNext, exec, playerctl next"
          ",XF86AudioPrev, exec, playerctl previous"

          "$mod, S, exec, hyprshot -m region"
          "$ctrl, mouse:272, exec, hyprshot -m region --clipboard-only"
          "$ctrl+SHIFT, mouse:272, exec, ocr-shot"

          # NOTE: use ctrl due to keyd re-mappings
          "ctrl, left, workspace, e-1"
          "ctrl, right, workspace, e+1"

          "$mod, return, exec, wezterm"

          # reload
          "$mod+SHIFT, r, exec, hyprctl reload && notify-send 'hyprland reloaded 👍'"

          # "$mod,space, exec, noctalia-shell ipc call launcher toggle"

          "$mod, v, exec, cliphist-pick"
          "$mod+ALT, v, exec, cliphist-pick"

          # quit - minimize Steam/Bitwarden to tray, kill everything else
          "$mod, Q, exec, smart-kill"

          "$mod, minus, togglespecialworkspace, magic"

          "$mod+shift, minus, movetoworkspace, +0"

          # Fullscreen
          "$mod, F, fullscreen, 1"
          "$mod+SHIFT, F, fullscreen, 3"
        ];

      bindel = [
        "$mod,XF86MonBrightnessDown, exec, hyprctl hyprsunset temperature -250"
        "$mod,XF86MonBrightnessUp, exec, hyprctl hyprsunset temperature +250"

        ",XF86MonBrightnessDown, exec, hyprctl hyprsunset gamma -10"
        ",XF86MonBrightnessUp, exec, hyprctl hyprsunset gamma +10"
      ];
    };

    extraConfig = ''
      misc:vfr = true

      bind = $mod, R,submap,resize
      submap=resize
      binde = , h, resizeactive, -85 0
      binde = , j, resizeactive, 0 85
      binde = , k, resizeactive, 0 -85
      binde = , l, resizeactive, 85 0
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.noctalia-shell.enable = true;

  environment = {
    systemPackages = with pkgs; [
      hyprsunset

      (pkgs.writeScriptBin "ocr-shot" (builtins.readFile ./ocr-shot.sh))

      (pkgs.writeShellScriptBin "smart-kill" ''
        class=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r ".class")
        if [ "$class" = "Steam" ] || [ "$class" = "Bitwarden" ]; then
          ${pkgs.xdotool}/bin/xdotool getactivewindow windowunmap
        else
          ${pkgs.hyprland}/bin/hyprctl dispatch killactive ""
        fi
      '')

      (tesseract5.override {
        enableLanguages = [
          "eng"
          "osd"
        ];
      })
      slurp
      grim
      xdotool

      hyprshot
      cliphist
      tuigreet
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      inputs.awww.packages.${pkgs.system}.awww
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
}
