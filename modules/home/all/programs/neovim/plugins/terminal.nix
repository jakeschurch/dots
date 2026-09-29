{ pkgs, ... }:
with pkgs.vimPlugins;
[
  flatten-nvim
  toggleterm-nvim
]
