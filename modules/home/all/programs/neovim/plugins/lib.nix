{ pkgs, ... }:
# Shared libraries, and plugins sourced outside nixpkgs. Each custom package
# lives under packages/ with a nix-update updateScript (`nix-update --flake
# <name>`, or bump all via `nix run .#update-packages`).
with pkgs;
[
  vimPlugins.plenary-nvim
  gitgood-lua
  presenting-nvim
  vim-symlink
  vim-venter
]
