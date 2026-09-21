#!/usr/bin/env bash

INPUT_FILE="${1:-}"

test -z "$INPUT_FILE" && echo "$INPUT_FILE does not exist" && exit 1

ffmpeg -i "$INPUT_FILE" \
  -movflags faststart \
  -pix_fmt yuv420p \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
  "${INPUT_FILE/.gif/.mp4}"
