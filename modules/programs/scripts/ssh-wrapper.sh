#!/usr/bin/env bash

host="$1"
shift

if command -v mosh &>/dev/null && mosh --ssh="ssh $host $*" -- true &>/dev/null; then
  exec mosh --ssh="ssh $host $*"
else
  exec ssh "$host $*"
fi
