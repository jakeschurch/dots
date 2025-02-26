#!/usr/bin/env bash

set -Eeuo pipefail

FLAKE_DIR=~/.dots
NIX_CONFIG=/etc/nix/nix.conf

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

update_nix_config() {
  local tmp="$(mktemp)"

  cat <<EOF >"$tmp"
extra-experimental-features = nix-command flakes auto-allocate-uids pipe-operator repl-automation
experimental-features = nix-command flakes auto-allocate-uids pipe-operator repl-automation
accept-flake-config = true
allow-dirty = true
allowed-users = root jake @wheel
always-allow-substitutes = true
auto-optimise-store = true
builders-use-substitutes = true
cores = 0
download-attempts = 3
fsync-metadata = false
http-connections = 0
keep-derivations = true
keep-outputs = true
max-jobs = auto
max-substitution-jobs = 0
preallocate-contents = true
pure-eval = true
substitute = true
substituters = https://nix-community.cachix.org?priority=1 https://cache.lix.systems?priority=2 https://cache.nixos.org?priority=3
trusted-public-keys = cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
trusted-substituters = https://nix-community.cachix.org?priority=1 https://cache.lix.systems?priority=2 https://cache.nixos.org?priority=3
trusted-users = root jake
warn-dirty = false
EOF

  if ! sudo diff $NIX_CONFIG "$tmp" &>/dev/null; then
    sudo install -m 0644 "$tmp" $NIX_CONFIG


    if [[ "$(uname -s)" == "Darwin" ]]; then
      sudo launchctl kickstart -k system/org.nixos.nix-daemon
    fi
  fi

  rm "$tmp"
}

flake_args=('--accept-flake-config' "--extra-experimental-features" "nix-command flakes ca-derivations auto-allocate-uids")

if [[ "$#" -gt 0 ]]; then
  flake_args+=("$@")
fi

build_flake() {
 NIX_BIN=$(command -v nom || command -v nix)

  $NIX_BIN build "$FLAKE_DIR" "${flake_args[@]}" &&
    "$FLAKE_DIR"/result/activate-user &&
    sudo "$FLAKE_DIR"/result/activate
}

# update_nix_config
build_flake "$@"
