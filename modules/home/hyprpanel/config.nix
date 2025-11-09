{
  bar.launcher.icon = "";
  bar.layouts = {
    "*" = {
      left = [
        "netstat"
        "storage"
        "ram"
        "cputemp"
        "cpu"
        "workspaces"
        "windowtitle"
      ];
      middle = [
        "weather"
        "clock"
        "notifications"
        "media"
      ];
      right = [
        "systray"
        "dashboard"
        "volume"
        "microphone"
        "network"
        "bluetooth"
        "hypridle"
        "hyprsunset"
      ];
    };
  };

  bar.autoHide = "fullscreen";
  bar.customModules.storage.labelType = "used/total";
  bar.customModules.storage.tooltipStyle = "percentage-bar";
  bar.customModules.updates.autoHide = true;
  bar.launcher.autoDetectIcon = true;
  bar.media.show_active_only = true;
  bar.notifications.hideCountWhenZero = true;
  bar.notifications.show_total = true;
  bar.workspaces.numbered_active_indicator = "highlight";
  bar.workspaces.showApplicationIcons = true;
  bar.workspaces.showWsIcons = true;
  menus.dashboard.stats.enable_gpu = true;
  menus.media.displayTime = true;
  menus.media.displayTimeTooltip = true;
  menus.volume.raiseMaximumVolume = true;
  tear = true;
}
