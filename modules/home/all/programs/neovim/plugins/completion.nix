{ pkgs, ... }:
with pkgs.vimPlugins;
[
  blink-cmp
  blink-emoji-nvim
  blink-pairs
  colorful-menu-nvim
  lspkind-nvim
]
