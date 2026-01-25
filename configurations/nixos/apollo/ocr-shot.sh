set -euo pipefail

TMP_IMG="$(mktemp --suffix=.png)"
TMP_TXT="$(mktemp)"

grim -g "$(slurp)" "$TMP_IMG"

# OCR
tesseract "$TMP_IMG" "$TMP_TXT" \
  -l eng \
  --psm 6 \
  --oem 1 >/dev/null 2>&1

wl-copy <"${TMP_TXT}.txt"
notify-send "OCR Complete" "Text copied to clipboard"

rm -f "$TMP_IMG" "$TMP_TXT.txt"
