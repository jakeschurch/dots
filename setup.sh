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

flake_args=('--accept-flake-config' "--extra-experimental-features" "nix-command flakes ca-derivations auto-allocate-uids dynamic-derivations")

if [[ "$#" -gt 0 ]]; then
  flake_args+=("$@")
fi

build_flake() {
  NIX_BIN=$(command -v nom || command -v nix)

  "$NIX_BIN" build "$FLAKE_DIR" "${flake_args[@]}" &&
    "$FLAKE_DIR"/result/activate-user &&
    sudo "$FLAKE_DIR"/result/activate
}

build_flake "$@"
