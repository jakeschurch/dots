#!/usr/bin/env bash
# vim:filetype=sh

set -eu

nix-collect-garbage -d 
nix store optimise
