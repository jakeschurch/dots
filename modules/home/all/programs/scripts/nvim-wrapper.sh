#!/usr/bin/env bash

rotate_logfile() {
  LOG_FILE="$HOME/.local/state/nvim/lsp.log"
  MAX_SIZE=1048576 # 1 MB in bytes

  if [ -f "$LOG_FILE" ] && [ "$(gstat -c %s "$LOG_FILE")" -gt "$MAX_SIZE" ]; then
    mv "$LOG_FILE" "$LOG_FILE.$(date -u +%Y-%m-%dT%H:%M:%S)"
    echo "" >"$LOG_FILE"
  fi
}

rotate_logfile
\nvim "$@"
