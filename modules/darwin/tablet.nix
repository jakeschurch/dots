{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.tablet;
in
{
  options.tablet = {
    enable = mkEnableOption "Wacom tablet support";
    pressureSensitivity = mkEnableOption "Pressure sensitivity" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # macOS drivers via Homebrew or direct driver install
    # Native Wacom driver for macOS handles pressure automatically
  };
}
