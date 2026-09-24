#!/usr/bin/env bash
# Open cliphist picker in a floating wezterm window.
# Captures the active window class first so we can send the right paste key
# after selection and focus returns to the original window.

ORIG_CLASS=$(hyprctl activewindow -j | jq -r '.class // ""')

ORIG_CLASS="$ORIG_CLASS" wezterm start --class cliphist-picker -- bash -c "
  cliphist list | fzf --no-sort | cliphist decode | wl-copy || exit 0
  sleep 0.2
  if [[ \"\$ORIG_CLASS\" == \"org.wezfurlong.wezterm\" ]]; then
    wtype -M ctrl -M shift -k v
  else
    wtype -M ctrl -k v
  fi
"
