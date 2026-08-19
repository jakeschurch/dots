{ pkgs, ... }:
with pkgs.vimPlugins;
[
  fzf-lua
  grug-far-nvim
  oil-git-status-nvim
  oil-lsp-diagnostics-nvim
  oil-nvim
]
