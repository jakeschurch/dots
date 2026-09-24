#!/usr/bin/env bash
# Usage: clipboard-key copy|paste
# Routes clipboard shortcut based on focused window:
#   All apps now use plain Ctrl+C / Ctrl+V (Wezterm now supports both)

ACTION="${1:-paste}"

export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH"

if [[ "$ACTION" == "copy" ]]; then
	wtype -M ctrl -k c
else
	wtype -M ctrl -k v
fi
