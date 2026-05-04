{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    obsidian
  ];

  # Excalidraw plugin auto-installs with Obsidian vault sync
  # Create vault + enable Excalidraw plugin for embedded diagram support
}
