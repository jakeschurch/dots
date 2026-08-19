{ pkgs, ... }:
with pkgs;
[
  add-subtract-ex-nvim
]
++ (with pkgs.vimPlugins; [
  friendly-snippets
  guess-indent-nvim
  hop-nvim
  kommentary
  luasnip
  nvim-autopairs
  nvim-surround
  nvim-ts-context-commentstring
  vim-matchup
  vim-repeat
  vim-unimpaired
])
