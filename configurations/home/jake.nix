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

  # Tablet calibration (Linux with xsetwacom)
  programs.tablet-calibration = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    deviceName = "Wacom Intuos S Pen stylus";
    mapToOutput = "HDMI-A-1";
  };

  # Only add this attribute on Linux
  xdg.configFile = lib.optionalAttrs pkgs.stdenv.isLinux {
    "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
