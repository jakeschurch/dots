#!/bin/sh
# vim:ft=sh

set -e

lockcmd=""

if "$(ss | grep -i ssh)"; then
	lockcmd="systemctl lock"
else
	lockcmd="systemctl suspend"
fi

exec xautolock -detectsleep \
	-time 30 \
	-lockaftersleep \
	-locker "$lockcmd" \
	-notify 30 \
	-notifier "notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds'"
