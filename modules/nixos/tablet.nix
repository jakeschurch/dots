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
    hardware.wacom.enable = true;

    services.udev.packages = with pkgs; [
      libwacom
      wacom-tools
    ];

    environment.systemPackages = with pkgs; [
      libwacom
      xournalpp
    ];
  };
}
