{ pkgs, ... }:
with pkgs.vimPlugins;
[
  lspsaga-nvim
  nvim-lspconfig
  otter-nvim
  tiny-inline-diagnostic-nvim
  trouble-nvim
]
