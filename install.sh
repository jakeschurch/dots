#!/usr/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
