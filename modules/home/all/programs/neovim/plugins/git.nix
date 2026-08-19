{ pkgs, ... }:
with pkgs.vimPlugins;
[
  diffview-nvim
  gitlinker-nvim
  gitsigns-nvim
  octo-nvim
  vim-dispatch
  vim-fugitive
  vim-git
]
