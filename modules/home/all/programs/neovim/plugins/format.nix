{ pkgs, ... }:
with pkgs.vimPlugins;
[
  conform-nvim
  nvim-lint
]
