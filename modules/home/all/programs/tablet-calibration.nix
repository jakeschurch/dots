{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.tablet-calibration;

  toggleScript = pkgs.writeShellApplication {
    name = "wacom-toggle-mode";
    runtimeInputs = [ pkgs.libnotify ];
    text = ''
      DEVICE="${cfg.hyprDeviceName}"
      STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/wacom-mode"
      mkdir -p "$(dirname "$STATE_FILE")"
      CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "normal")

      if [ "$CURRENT" = "normal" ]; then
        echo "pro" > "$STATE_FILE"
        hyprctl keyword "device[$DEVICE]:accel_profile" flat
        hyprctl keyword "device[$DEVICE]:sensitivity" "${toString cfg.proDrawingMode.sensitivity}"
        notify-send -t 1500 "Wacom" "Pro mode"
      else
        echo "normal" > "$STATE_FILE"
        hyprctl keyword "device[$DEVICE]:accel_profile" adaptive
        hyprctl keyword "device[$DEVICE]:sensitivity" "0"
        notify-send -t 1500 "Wacom" "Normal mode"
      fi
    '';
  };
in
{
  options.programs.tablet-calibration = {
    enable = mkEnableOption "Wacom tablet config for Hyprland/Wayland";

    hyprDeviceName = mkOption {
      type = types.str;
      default = "wacom-intuos-s-pen";
      description = "Device name from 'hyprctl devices'";
    };

    mapToOutput = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Map tablet to output (e.g. DP-1)";
    };

    proDrawingMode = {
      enable = mkEnableOption "Pro drawing mode (flat accel, minimal smoothing)";

      sensitivity = mkOption {
        type = types.float;
        default = 0.0;
        description = "Pointer sensitivity in pro mode (-1.0 to 1.0)";
      };
    };

    toggleKeybind = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = ''
        "$mod, T"
      '';
      description = "Hyprland keybind to toggle pro drawing mode";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optionals cfg.proDrawingMode.enable [ toggleScript ];

    wayland.windowManager.hyprland.settings = mkMerge [
      (mkIf (cfg.mapToOutput != null) {
        input.tablet.output = cfg.mapToOutput;
      })
      (mkIf cfg.proDrawingMode.enable {
        device = [
          {
            name = cfg.hyprDeviceName;
            accel_profile = "adaptive";
            sensitivity = 0;
          }
        ];
      })
      (mkIf (cfg.proDrawingMode.enable && cfg.toggleKeybind != null) {
        bind = [ "${cfg.toggleKeybind}, exec, wacom-toggle-mode" ];
      })
    ];
  };
}
