{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.wayland.windowManager.hyprland;
  hyprlandEnabled = cfg.enable;
in
{
  config = mkIf hyprlandEnabled {
    wayland.windowManager.hyprland.settings = {
      input = {
        tablet = {
          transform = 0;
          region_position = "0 0";
          region_size = "auto";
          left_click_emulation = false;
        };
      };

      bind = [
        # Optional: tablet-specific binds
        # "SUPER, P, exec, [float] xournalpp"
      ];
    };
  };
}
