#!/usr/bin/env bash

if [ "$(uname -s)" == "Darwin" ]; then
  nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
fi

curl -sSf -L https://install.lix.systems/lix | sh -s -- uninstall
