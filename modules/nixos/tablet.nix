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
    enable = mkEnableOption "Wacom tablet support via OpenTabletDriver";
  };

  config = mkIf cfg.enable {
    hardware.opentabletdriver.enable = true;
  };
}
