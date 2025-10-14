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

  home.packages = lib.mkIf pkgs.stdenv.isLinux (
    with pkgs;
    [
      hyprsunset
    ]
  );

  # Only add this attribute on Linux
  xdg.configFile = lib.optionalAttrs pkgs.stdenv.isLinux {
    "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
