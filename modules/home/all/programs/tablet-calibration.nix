{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.programs.tablet-calibration;
in
{
  options.programs.tablet-calibration = {
    enable = mkEnableOption "Tablet calibration and xsetwacom config";

    deviceName = mkOption {
      type = types.str;
      default = "Wacom Intuos S Pen stylus";
      description = "Tablet device name from 'xsetwacom list devices'";
    };

    pressureCurve = mkOption {
      type = types.listOf types.int;
      default = [ 5 10 90 95 ];
      description = "Pressure curve [start-low, start-high, end-high, end-low]";
    };

    mapToOutput = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Map tablet to specific output (e.g. HDMI-1)";
    };

    buttonMappings = mkOption {
      type = types.attrsOf types.str;
      default = {
        button2 = "key ctrl z"; # Undo
        button3 = "key shift";  # Modifier
      };
      description = "Pen button mappings";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xf86-input-wacom
    ];

    home.activation.wacomCalibration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Only run on Linux with xsetwacom available
      if command -v xsetwacom &>/dev/null; then
        DEVICE="${cfg.deviceName}"

        # Set pressure curve
        xsetwacom set "$DEVICE" PressureCurve ${lib.concatStringsSep " " (map toString cfg.pressureCurve)} 2>/dev/null || true

        ${lib.optionalString (cfg.mapToOutput != null) ''
        # Map to specific output
        xsetwacom set "$DEVICE" MapToOutput ${cfg.mapToOutput} 2>/dev/null || true
        ''}

        # Apply button mappings
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (button: action: ''
          xsetwacom set "$DEVICE" Button ${lib.removePrefix "button" button} "${action}" 2>/dev/null || true
        '') cfg.buttonMappings)}
      fi
    '';
  };
}
