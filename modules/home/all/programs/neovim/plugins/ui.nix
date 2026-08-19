{ pkgs, ... }:
with pkgs;
[
  national-parks-themes
]
++ (with pkgs.vimPlugins; [
  alpha-nvim
  lualine-nvim
  noice-nvim
  nui-nvim
  nvim-web-devicons
  snacks-nvim
  which-key-nvim
  nvim-colorizer-lua
  rainbow-delimiters-nvim
  image-nvim
])
