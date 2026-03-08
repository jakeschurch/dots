{
  flake,
  pkgs,
  lib,
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
    inputs.noctalia.nixosModules.default

    # MicroVM host configuration for K3s cluster
    inputs.vmetal.nixosModules.microvm-host
    inputs.vmetal.nixosModules.k3s-cluster
  ];

  environment.variables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };

  services.microvm-host = {
    enable = true;
    network = {
      gateway = "192.168.100.1";
      subnet = "192.168.100.0/24";
      externalInterface = "enp5s0";
    };
  };

  services.k3s-cluster = {
    enable = true;
    token = "my-cluster-token-12345";
    vip = "192.168.100.100";

    embeddedRegistry = {
      enable = true;
      mirrors = [
        "docker.io"
        "registry.k8s.io"
      ];
    };

    cilium.enable = true;
    argocd = {
      enable = true;
      targetRevision = "v1";
      path = "vmetal/manifests";
    };

    network = {
      prefix = "192.168.100";
      firstServerIp = "192.168.100.10";
      gateway = "192.168.100.1";
      dns = "192.168.100.1";
    };

    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

    servers.k3s-server-1 = {
      ip = "192.168.100.10";
      mac = "02:00:00:00:00:10";
      initial = true;
      vsockCid = 10;
    };

    servers.k3s-server-2 = {
      ip = "192.168.100.11";
      mac = "02:00:00:00:00:11";
      vsockCid = 11;
    };

    servers.k3s-server-3 = {
      ip = "192.168.100.12";
      mac = "02:00:00:00:00:12";
      vsockCid = 12;
    };

    workers.k3s-worker-1 = {
      ip = "192.168.100.20";
      mac = "02:00:00:00:00:20";
      vsockCid = 20;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-2 = {
      ip = "192.168.100.21";
      mac = "02:00:00:00:00:21";
      vsockCid = 21;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-3 = {
      ip = "192.168.100.22";
      mac = "02:00:00:00:00:22";
      vsockCid = 22;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-4 = {
      ip = "192.168.100.23";
      mac = "02:00:00:00:00:24";
      vsockCid = 23;
      mem = 20000;
      dataDisk = 250;
      passthroughDevices = [
        {
          bus = "pci";
          path = "0000:0c:00.0";
        }
      ];
    };
  };

  # NAT for microVM external network access
  networking.nat.externalInterface = "enp5s0";

  networking.nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
      DNSOverTLS = "opportunistic";
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.noctalia-shell.enable = true;

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;

      plugins =
        with inputs.hyprland-plugins.packages.${pkgs.system};
        [
          hyprbars
          hyprwinwrap
        ]
        ++ (with pkgs; [
          inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
          hyprsunset
        ]);

      settings = {
        exec-once = [
          "systemctl --user enable --now hyprsunset.service"
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

        layout = {
          single_window_aspect_ratio = "4 3";
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
          "__NV_PRIME_RENDER_OFFLOAD,1"
          "__VK_LAYER_NV_optimus,NVIDIA_only"
        ];

        xwayland = {
          force_zero_scaling = true;
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
            "$mod, mouse:272, exec, hyprshot -m region --clipboard-only"
            "$mod+SHIFT, mouse:272, exec, ocr-shot"

            "$mod,XF86MonBrightnessDown, exec, hyprctl hyprsunset temperature -250"
            "$mod,XF86MonBrightnessUp, exec, hyprctl hyprsunset temperature +250"

            ",XF86MonBrightnessDown, exec, hyprctl hyprsunset gamma -10"
            ",XF86MonBrightnessUp, exec, hyprctl hyprsunset gamma +10"

            # NOTE: use ctrl due to keyd re-mappings
            "ctrl, left, workspace, e-1"
            "ctrl, right, workspace, e+1"

            "$mod, return, exec, wezterm"

            # reload
            "$mod+SHIFT, r, exec, hyprctl reload && notify-send 'hyprland reloaded 👍'"

            # "$mod,space, exec, noctalia-shell ipc call launcher toggle"

            "$mod+SHIFT, v, exec, cliphist-pick"
            "$mod+ALT, v, exec, cliphist-pick"

            # quit - minimize Steam/Bitwarden to tray, kill everything else
            "$mod, Q, exec, smart-kill"

            "$mod, minus, togglespecialworkspace, magic"

            "$mod+shift, minus, movetoworkspace, +0"

            # Fullscreen
            "SUPER, F, fullscreen, 1"
            "SUPER+SHIFT, F, fullscreen, 3"
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
  };

  environment = {
    systemPackages = with pkgs; [
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
            backspace = "C-backspace";
            v = "C-v";
            c = "C-c";

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

  environment.variables.HYPRSHOT_DIR = "/home/jake/Pictures/Screenshots";

  services.greetd = {
    enable = true;
    settings = {
      # default_session =
      #   let
      #     tuigreetArgs = builtins.concatStringsSep " " [
      #       "--power-shutdown 'sudo systemctl poweroff'"
      #       "--time"
      #       "--asterisks"
      #       "--cmd hyprland"
      #     ];
      #   in
      #   {
      #     command = "${pkgs.tuigreet}/bin/tuigreet ${tuigreetArgs}";
      #     user = "jake";
      #   };
      default_session = {
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
        user = "jake";
      };
    };
  };

  # hyprshot mouse daemon // ocr-shot
  # Set up proper permissions for input devices
  users.groups.input = { };
  users.users.jake.extraGroups = [ "input" ];

  services.udev.extraRules = ''
    KERNEL=="event*", GROUP="input", MODE="0660"
    SUBSYSTEM=="input", GROUP="input", MODE="0660"
  '';

}
