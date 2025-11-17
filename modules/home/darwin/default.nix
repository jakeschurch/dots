{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pngpaste
  ];

  imports = [
    ./aerospace.nix
  ];
}
