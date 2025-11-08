{
  pkgs,
  flake,
  lib,
  config,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      obs-studio
      nixgl.nixVulkanIntel
      vulkan-tools
      vulkan-validation-layers
      rofi
      spotify
      docker
      wmctrl
      xbanish
      playerctl
      xbindkeys
      xautolock
      yubikey-manager
      ethtool
      # xev-1.2.4
      xclip

      hyprlock
      hypridle
    ]
    ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));

  home.file = {
    "${config.xdg.configHome}/hypr/theme/hyprlock/transparent/wall2.jpg".source = ./wall2.jpg;
    "${config.xdg.configHome}/hypr/theme/hyprlock/transparent/fg2.png".source = ./fg2.png;
  };

  fonts.fontconfig.enable = true;

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "${lib.getExe pkgs.hyprlock}";
          before_sleep_cmd = "${lib.getExe pkgs.hyprlock}";
        };
        listener = [
          {
            timeout = 3600;
            on-timeout = "${lib.getExe pkgs.hyprlock}";
          }
          {
            timeout = 5400;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "${config.xdg.configHome}/hypr/theme/hyprlock/transparent/wall2.jpg";
        }
        {
          monitor = "";
          zindex = 1;
          keep_aspect_ratio = true;
          rounding = 0;
          border_size = 0;
          path = "${config.xdg.configHome}/hypr/theme/hyprlock/transparent/fg2.png";
        }
      ];
      general = {
        no_fade_in = true;
        no_fade_out = true;
        hide_cursor = true;
        grace = 0;
        disable_loading_bar = true;
      };
      label = [
        # Date - upper right corner
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
          color = "rgba(255, 255, 255, 0.8)";
          font_size = 28;
          font_family = "Overpass Nerd Font Italic";
          position = "-40, -40";
          halign = "right";
          valign = "top";
          zindex = 2;
        }
        # Time - single line behind mountains
        {
          monitor = "";
          text = ''cmd[update:1000] echo -e "$(date +"%I:%M %p")"'';
          color = "rgba(255, 255, 255, 0.95)";
          font_size = 400;
          font_family = "Overpass Nerd Font Bold";
          position = "500, 160";
          halign = "center";
          valign = "center";
          zindex = 0;
        }
      ];
      "input-field" = [
        {
          monitor = "";
          size = "280, 70";
          outline_thickness = 2;
          outer_color = "rgba(0, 0, 0, 0.2)";
          inner_color = "rgba(0, 0, 0, 0.8)";
          font_color = "rgba(255, 255, 255, 1)";
          fade_on_empty = false;
          rounding = 16;
          dots_size = 0.15;
          dots_spacing = 0.35;
          dots_center = true;
          check_color = "rgba(255, 255, 255, 1)";
          placeholder_text = ''<span foreground="##ffffff">Enter Password</span>'';
          hide_input = false;
          font_family = "Overpass Nerd Font";
          font_size = 16;
          position = "0, -200";
          halign = "center";
          valign = "center";
          zindex = 2;
        }
      ];
    };
  };
}
