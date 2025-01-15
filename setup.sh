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

flake_args=('--accept-flake-config' "--extra-experimental-features" "nix-command flakes pipe-operators ca-derivations" "$*")

build_flake() {
  if [ ! -d "$FLAKE_DIR" ]; then
    echo "Cloning jakeschurch/dots"
    git clone https://github.com/jakeschurch/dots.git "$FLAKE_DIR"
  fi

  # use nom if available, otherwise use nix to build package
  if command -v nom &>/dev/null; then
    NIX_BIN="$(command -v nom)"
  else
    NIX_BIN="$(command -v nix)"
  fi

  $NIX_BIN build "$FLAKE_DIR" "${flake_args[@]}" &&
    "$FLAKE_DIR"/result/activate-user &&
    sudo "$FLAKE_DIR"/result/activate
}

create_ccache_dir
build_flake "$@"
