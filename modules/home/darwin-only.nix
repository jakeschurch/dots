{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pngpaste
  ];
}
