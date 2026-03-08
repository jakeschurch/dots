#!/usr/bin/env bash
# Open cliphist picker for images only.
# Works with any image MIME type stored in cliphist.

ORIG_CLASS=$(hyprctl activewindow -j | jq -r '.class // ""')

ORIG_CLASS="$ORIG_CLASS" wezterm start --class cliphist-picker -- bash -c "
  cliphist list | while read -r id type content; do
    if [[ \"\$type\" == image/* ]]; then
      echo \"\$id\"
    fi
  done | fzf --no-sort | cliphist decode | wl-copy || exit 0
  
  sleep 0.2
  if [[ \"\$ORIG_CLASS\" == \"org.wezfurlong.wezterm\" ]]; then
    wtype -M ctrl -M shift -k v
  else
    wtype -M ctrl -k v
  fi
"
