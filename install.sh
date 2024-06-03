#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "extra-experimental-features = nix-command flakes repl-flake" | sudo tee -a /etc/nix/nix.conf
