#!/usr/bin/env bash

set -Eeou pipefail

usage() {
  cat <<EOF
Usage $(basename "$0") add <owner/repo>...
      $(basename "$0") remove <owner/repo>...
      $(basename "$0") update-file <file>

Manage and update GitHub repository information in a JSON file.

Commands:
  add <owner/repo>...      Add one or more repositories to the file.
  remove <owner/repo>...   Remove one or more repositories from the file.
  update-file <file>       Update the specified file with the latest revisions, references, and sha256 hashes.

Examples:
  $(basename "$0") add soywod/himalaya nvim-treesitter/nvim-treesitter
  $(basename "$0") remove soywod/himalaya
  $(basename "$0") update-file versions.json
EOF
  exit 1
}

trap_exit() {
  rm -rf "$TMP"
}

trap_error() {
  trap_exit
  local exit_code=$?
  local line_no=${BASH_LINENO[0]}
  local func_name=${FUNCNAME[1]:-main}
  local script_name=$(basename "${BASH_SOURCE[1]:-}")

  log error "Script '$script_name', function '$func_name', line $line_no, exit code $exit_code"
  exit "$exit_code"
}

trap 'trap_error' ERR

# Configuration
TMP="$(mktemp -d)"
CACHE_DIR="${TMP}/cache"
MAX_JOBS=4
LOG_LEVEL="info" # Can be "debug", "info", "warn", or "error"

# Logging function
log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  if [[ "$level" == "debug" && "$LOG_LEVEL" != "debug" ]]; then
    return
  fi

  case "$level" in
  debug) echo -e "[${timestamp}] \033[34mDEBUG\033[0m: $message" ;;
  info) echo -e "[${timestamp}] \033[32mINFO\033[0m: $message" ;;
  warn) echo -e "[${timestamp}] \033[33mWARN\033[0m: $message" >&2 ;;
  error) echo -e "[${timestamp}] \033[31mERROR\033[0m: $message" >&2 ;;
  *) echo -e "[${timestamp}] $message" ;;
  esac
}

# Validate input format
validate_input() {
  local input="$1"
  if ! [[ "$input" =~ ^[^/]+/[^/]+$ ]]; then
    log error "Invalid input format: $input. Expected 'owner/repo'."
    return 1
  fi
}

# Sanitize repository name for use in file paths
sanitize_repo_name() {
  local repo="$1"
  echo "$repo" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

# Lookup the latest revision, reference, and sha256 hash for a plugin
lookup() {
  local _dir="$1"
  local owner="$2"
  local repo="$3"

  local sanitized_repo
  sanitized_repo=$(sanitize_repo_name "$repo")
  local tmpfile="$_dir/${owner}_${sanitized_repo}"
  local cache_file="${CACHE_DIR}/${owner}_${sanitized_repo}.json"

  # Use cached data if available
  if [[ -f "$cache_file" ]]; then
    log debug "Using cached data for $owner/$repo"
    cp "$cache_file" "$tmpfile"
    return
  fi

  log info "Fetching data for $owner/$repo"

  # Fetch the default branch
  local ref
  ref=$(gh api "/repos/$owner/$repo" | jq -r '.default_branch')

  # Fetch the latest revision
  local commit_info
  commit_info=$(gh api --cache "5h" "/repos/$owner/$repo/branches/$ref")

  local rev
  rev=$(echo "$commit_info" | jq -r '.commit.sha')

  # Compute the sha256 hash using nix-prefetch-url
  local sha256
  sha256=$(nix-prefetch-url --unpack "https://github.com/$owner/$repo/archive/$rev.tar.gz" 2>/dev/null || true)

  # Generate the JSON object
  jq -n \
    --arg owner "$owner" \
    --arg repo "$repo" \
    --arg rev "$rev" \
    --arg ref "$ref" \
    --arg sha256 "$sha256" \
    '{owner: $owner, repo: $repo, rev: $rev, ref: $ref, sha256: $sha256}' \
    >"$tmpfile"

  # Cache the result
  mkdir -p "$CACHE_DIR"
  cp "$tmpfile" "$cache_file"
}

# Add one or more repositories to the file
add() {
  local file="$1"
  shift
  declare -a repos=("$@")

  if [[ ! -f "$file" ]]; then
    log info "Creating new file: $file"
    echo '[]' >"$file"
  fi

  for repo in "${repos[@]}"; do
    validate_input "$repo" || continue

    IFS='/' read -r owner repo_name <<<"$repo"

    # Check if the repo already exists in the file
    if jq -e --arg owner "$owner" --arg repo "$repo_name" '.[] | select(.owner == $owner and .repo == $repo)' "$file" >/dev/null; then
      log warn "Repository $owner/$repo_name already exists in $file. Skipping."
      continue
    fi

    # Fetch the latest data
    lookup "$TMP" "$owner" "$repo_name"

    # Add the new entry to the file
    local sanitized_repo
    sanitized_repo=$(sanitize_repo_name "$repo_name")
    local tmpfile="${TMP}/${owner}_${sanitized_repo}"
    jq --slurpfile new_entry "$tmpfile" '. + $new_entry' "$file" >"${file}.tmp"
    mv "${file}.tmp" "$file"

    log info "Added $owner/$repo_name to $file"
  done
}

# Remove one or more repositories from the file
remove() {
  local file="$1"
  shift
  declare -a repos=("$@")

  if [[ ! -f "$file" ]]; then
    log error "File $file not found."
    exit 1
  fi

  for repo in "${repos[@]}"; do
    validate_input "$repo" || continue

    IFS='/' read -r owner repo_name <<<"$repo"

    # Remove the repo from the file
    jq --arg owner "$owner" --arg repo "$repo_name" 'del(.[] | select(.owner == $owner and .repo == $repo))' "$file" >"${file}.tmp"
    mv "${file}.tmp" "$file"

    log info "Removed $owner/$repo_name from $file"
  done
}

# Update the file with the latest revisions, references, and sha256 hashes
update_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    log error "File $file not found."
    exit 1
  fi

  declare -a args
  args=("$(jq -r '.[] | [.owner, .repo] | join(":")' "$file")")

  download "${args[@]}"
  generate_file "$file"
}

# Download information for multiple plugins in parallel
download() {
  declare -a args
  IFS=$'\n' read -r -d '' -a args < <(echo "$@" | tr " " "\n" && printf '\0')

  local running_jobs=0

  for arg in "${args[@]}"; do
    IFS=':' read -r owner repo <<<"$arg"

    # Limit the number of concurrent jobs
    if ((running_jobs >= MAX_JOBS)); then
      wait -n
      running_jobs=$((running_jobs - 1))
    fi

    lookup "$TMP" "$owner" "$repo" &
    running_jobs=$((running_jobs + 1))
  done

  wait
}

# Generate the final versions.json file
generate_file() {
  local file="$1"

  if [[ ! -s "$file" ]]; then # Check if the file is empty
    log error "The file $file is empty, no data to process."
    exit 1
  fi

  declare -a args
  IFS=$'\n' read -r -d '' -a args < <(find "$TMP" -type f -name "*.json" && printf '\0')

  local json_files=()
  for arg in "${args[@]}"; do
    if [[ -f "$arg" && "$arg" == *.json ]]; then
      json_files+=("$arg")
    fi
  done

  if [[ ${#json_files[@]} -eq 0 ]]; then
    log error "No valid JSON files found in $TMP"
    exit 1
  fi

  jq -s '.' "${json_files[@]}" >"$file"
  log info "Updated $file"
}

# Main entry point
if [[ $# -eq 0 ]]; then
  usage
fi

case "$1" in
add)
  shift
  add "versions.json" "$@"
  ;;
remove)
  shift
  remove "versions.json" "$@"
  ;;
update-file)
  shift
  update_file "$@"
  ;;
*)
  usage
  ;;
esac
