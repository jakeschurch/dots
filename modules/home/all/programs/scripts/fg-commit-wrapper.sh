#!/usr/bin/env bash

set -e

COMMIT_MSG_FILE=$(mktemp)

# Capture commit message from arguments
if [[ $# -gt 0 ]]; then
  echo "$*" >"$COMMIT_MSG_FILE"
else
  git commit --dry-run &>/dev/null || exit 1 # Ensure we're in a valid git repo
  git status --short | grep -qE '^(A|M|D|R|C|U|??) ' || {
    echo "No changes to commit"
    exit 1
  }
  $EDITOR "$COMMIT_MSG_FILE"
fi

# Remove default Git commit message comments
perl -i.bak -ne 'print unless(m/^. Please enter the commit message/..m/^#$/)' "$COMMIT_MSG_FILE"

# Extract story prefix from branch name
STORY_PREFIX=$(git symbolic-ref --short HEAD | grep -Eo 'sc-[0-9]+')
if [[ -n "$STORY_PREFIX" ]] && ! grep -q "$STORY_PREFIX" <<<"$(head -n 1 "$COMMIT_MSG_FILE")"; then
  sed -i.bak "1s/^/[${STORY_PREFIX}] /" "$COMMIT_MSG_FILE"
fi

# Append Signed-off-by trailer
SOB=$(git var GIT_COMMITTER_IDENT | sed -n 's/^\(.*>\).*$/Signed-off-by: \1/p')
git interpret-trailers --in-place --trailer "$SOB" "$COMMIT_MSG_FILE"

# Ensure a newline at the end of the commit message
perl -i.bak -pe 'print "\n" if !$first_line++' "$COMMIT_MSG_FILE"

# Perform the actual commit
git commit -F "$COMMIT_MSG_FILE"

# Clean up
test -f "$COMMIT_MSG_FILE" && rm "$COMMIT_MSG_FILE"
