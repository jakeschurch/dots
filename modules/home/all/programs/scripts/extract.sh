#!/usr/bin/env bash

set -e

usage() {
  echo "Usage: extract <file>"
  echo "Extracts various archive formats"
  exit 1
}

if [ -z "$1" ]; then
  usage
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Error: $FILE is not a valid file"
  exit 1
fi

extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.txz) tar xJf "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.7z) 7z x "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.xz) unxz "$1" ;;
    *.zst) unzstd "$1" ;;
    *)
      echo "Error: unsupported archive format: $1"
      exit 1
      ;;
  esac
}

extract "$FILE"
