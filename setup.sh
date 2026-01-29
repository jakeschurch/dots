#!/usr/bin/env bash

set -Eeuo pipefail

nix run "$*" --accept-flake-config
