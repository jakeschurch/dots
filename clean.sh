#!/usr/bin/env bash
# vim:filetype=sh

set -eu

pushd "$HOME" &>/dev/null || exit

echo "removing all nix symlinks from $HOME"

fd --no-ignore '^result(-\d*)?' \
  --type symlink \
  -x sh -c "echo 'removing {}' && rm {}"

echo "done"
popd &>/dev/null || exit

nix-collect-garbage -d
nix store optimise
