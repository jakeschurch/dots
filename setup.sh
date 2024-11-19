#!/usr/bin/env bash

set -Eeuo pipefail

FLAKE_DIR=~/.dots

create_ccache_dir() {
  if [ ! -d /nix/var/cache/ccache ]; then
    sudo mkdir -m0770 -p /nix/var/cache/ccache

    if [[ "$OSTYPE" == "darwin"* ]]; then
      nix-shell -p coreutils --run 'sudo chown --reference=/nix/store /nix/var/cache/ccache'
    else
      sudo chown --reference=/nix/store /nix/var/cache/ccache
    fi
  fi

}

build_flake() {
  if [ ! -d "$FLAKE_DIR" ]; then
    echo "Cloning jakeschurch/dots"
    git clone https://github.com/jakeschurch/dots.git "$FLAKE_DIR"
  fi

  # use nom if available, otherwise use nix to build it
  if command -v nom &>/dev/null; then
    nom build "$FLAKE_DIR" "$@"
  else
    nix build "$FLAKE_DIR" --extra-experimental-features 'nix-command flakes' "$@"
  fi && "$FLAKE_DIR"/result/activate-user && sudo "$FLAKE_DIR"/result/activate
}

create_ccache_dir
build_flake "$@"
