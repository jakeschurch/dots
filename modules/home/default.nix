{ flake, ... }:
{
  imports = [
    ./all
  ];

  programs.bottom.enable = true;

  home.username = flake.config.me.username;
}
