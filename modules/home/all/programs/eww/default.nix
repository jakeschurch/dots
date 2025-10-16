{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  programs.eww = {
    enable = true;
    configDir = ./config;
  };
}
