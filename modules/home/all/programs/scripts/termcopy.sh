#!/usr/bin/env bash
# vim:filetype=sh
# termcopy — read stdin, copy to system clipboard. Shells out by OS/display server.

set -e

case "$(uname -s)" in
Darwin)
  pbcopy
  ;;
Linux)
  if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "termcopy: no clipboard tool found (wl-copy/xclip/xsel)" >&2
    exit 1
  fi
  ;;
*)
  echo "termcopy: unsupported OS $(uname -s)" >&2
  exit 1
  ;;
esac
