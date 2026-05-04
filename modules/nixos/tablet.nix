{
  pkgs,
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
    pressureSensitivity = mkEnableOption "Pressure sensitivity (Wayland)" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.udev.packages = with pkgs; [
      libwacom
    ];

    environment.systemPackages = with pkgs; [
      libwacom
    ];
  };
}
