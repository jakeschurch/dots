{
  flake,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  programs.tablet-calibration = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    hyprDeviceName = "wacom-intuos-s-pen";
    mapToOutput = "HDMI-A-1";
    proDrawingMode.enable = true;
    toggleKeybind = "$mod, T";
  };

  # Only add this attribute on Linux
  xdg.configFile = lib.optionalAttrs pkgs.stdenv.isLinux {
    "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
