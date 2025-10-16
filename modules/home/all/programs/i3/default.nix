{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  xsession.windowManager.i3 = {
    enable = false;
    package = pkgs.i3-gaps;
    extraConfig = builtins.readFile ./config;
    config = null;
  };

  home.file.".config/i3blocks" = {
    source = ./i3blocks;
    recursive = true;
  };

  home.packages = with pkgs; [
    i3blocks
  ];
}
