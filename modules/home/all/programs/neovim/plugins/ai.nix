{ pkgs, ... }:
with pkgs.vimPlugins;
[
  copilot-lua
  copilot-vim
  sidekick-nvim
]
