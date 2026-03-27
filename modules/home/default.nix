{
  flake,
  ...
}:
{
  imports = [
    ./all
  ];

  programs.bottom.enable = true;
  programs.home-manager.enable = true;

  home.username = flake.config.me.username;
}
