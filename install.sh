#!/usr/bin/env bash

check_if_installed() {
  if command -v nix &>/dev/null; then
    echo "Nix is already installed."
    exit 0
  else
    echo "Nix is not installed. Proceeding with installation..."
  fi
}

install() {
  bash <(curl -L https://nixos.org/nix/install) --daemon
}

main() {
  # check_if_installed
  install
  echo "Nix installation completed."
}

main
