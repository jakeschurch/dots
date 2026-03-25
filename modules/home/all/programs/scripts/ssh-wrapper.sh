#!/usr/bin/env bash

host="$1"
shift

exec ssh "$host" "$@"
