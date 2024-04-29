#!/usr/bin/env bash
# vim:filetype=sh

set -e

git-sha() {
	echo "${1:-1}" | awk -F' ' '{print $1}' |
		xargs -I {} git rev-list --abbrev-commit HEAD --max-count={}
}

git-mainbranch() {
	git branch | grep -E 'main|master|develop' | head -1 | xargs
}

git-commit() {
	echo "$@" | xargs -0 -I {} git commit -s -m "{}"
}

git-rebase() {
	git rebase -i "${1:-$(git-mainbranch)}"
}

case "${1:-}" in
*)
	"${@:-1}"
	;;
esac
