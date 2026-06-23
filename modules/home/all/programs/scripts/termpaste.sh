#!/usr/bin/env bash
# vim:filetype=sh
# termpaste — write system clipboard to stdout. Shells out by OS/display server.

set -e

case "$(uname -s)" in
Darwin)
  pbpaste
  ;;
Linux)
  if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-paste >/dev/null 2>&1; then
    wl-paste --no-newline
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -out
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --output
  else
    echo "termpaste: no clipboard tool found (wl-paste/xclip/xsel)" >&2
    exit 1
  fi
  ;;
*)
  echo "termpaste: unsupported OS $(uname -s)" >&2
  exit 1
  ;;
esac
