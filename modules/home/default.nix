{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    ./all
  ];

  programs.bottom.enable = true;

  home.username = flake.config.me.username;

  hyprland.enable = pkgs.stdenv.isLinux;
}
