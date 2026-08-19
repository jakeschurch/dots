{ pkgs, ... }:
with pkgs.vimPlugins;
[
  nvim-dap
  nvim-dap-ui
  nvim-dap-virtual-text
  nvim-nio
]
