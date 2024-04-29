#!/usr/bin/env bash
# vim:filetype=sh

set -e

URL_PREFIX="https://noirlab.edu/public/images/page" seq 1 186 |
	xargs -I{} curl "$URL_PREFIX/{}/" |
	grep -E '.*(/public/media/archives.*jpg).*' |
	sed -E -e 's_.*(/public/media/archives.*jpg).*_https://noirlab.edu\1_g' -e 's/thumb300y/wallpaper5/g' |
	xargs -I {} -n 1 wget {}
