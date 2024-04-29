#!/usr/bin/env bash

set -euo pipefail

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

create_ccache_dir

# use nom if available, otherwise use nix to build it
if command -v nom &> /dev/null; then
  nom build .#  --show-trace
else
  nix build .#  --show-trace
fi && sudo ./result/activate
