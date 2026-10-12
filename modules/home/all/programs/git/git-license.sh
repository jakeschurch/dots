#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo 'Usage: git license <license> [--name NAME] [--year YEAR] [--force]'
  echo '       git license --list'
}

fetch() {
  curl --fail --silent --show-error --location --connect-timeout 10 --max-time 30 \
    -H 'Accept: application/vnd.github+json' "https://api.github.com/licenses$1"
}

license=''
name=''
year=$(date +%Y)
force=false

while (($#)); do
  case "$1" in
    --help | -h)
      usage
      exit 0
      ;;

    --list)
      fetch '?per_page=100' | jq -er '.[] | "\(.key)\t\(.name)"'
      exit 0
      ;;

    --name | --year)
      if (($# < 2)) || [[ -z "$2" ]]; then
        echo "Missing value for $1" >&2
        exit 1
      fi
      if [[ "$1" == --name ]]; then name=$2; else year=$2; fi
      shift
      ;;

    --force) force=true ;;

    -*)
      usage >&2
      exit 1
      ;;

    *)
      if [[ -n "$license" ]]; then
        usage >&2
        exit 1
      fi
      license=$1
      ;;
  esac
  shift
done

if [[ ! "$license" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || [[ ! "$year" =~ ^[0-9]{4}$ ]]; then
  usage >&2
  exit 1
fi

license=${license,,}

if [[ -e LICENSE || -L LICENSE ]] && ! "$force"; then
  echo 'LICENSE already exists; use --force to replace it.' >&2
  exit 1
fi

if [[ -z "$name" ]]; then name=$(git config user.name || true); fi
if [[ -z "$name" ]]; then
  echo 'Set git config user.name or pass --name NAME.' >&2
  exit 1
fi

# Validate and substitute before opening LICENSE, so failed downloads preserve it.
body=$(fetch "/$license" | jq -er --arg year "$year" --arg name "$name" '
  .body | select(type == "string" and length > 0)
  | split("[year]") | join($year)
  | split("[fullname]") | join($name)
')

if "$force"; then
  printf '%s\n' "$body" >LICENSE
else
  (
    set -o noclobber
    printf '%s\n' "$body" >LICENSE
  )
fi

echo "Created LICENSE ($license)."
