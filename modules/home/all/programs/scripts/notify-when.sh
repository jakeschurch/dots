#!/usr/bin/env bash
# notify-when: Run a command and notify on success
# Usage: notify-when [-t <seconds>] <command> [args...]
#   -t, --timeout  Timeout in seconds (default: 300 = 5 minutes)
#
# Examples:
#   notify-when ping -c 10 1.1.1.1
#   notify-when -t 600 long-running-build

set -e

TIMEOUT=300

# Parse arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-t | --timeout)
		TIMEOUT="$2"
		shift 2
		;;
	-t=* | --timeout=*)
		TIMEOUT="${1#*=}"
		shift
		;;
	-h | --help)
		echo "Usage: notify-when [-t <seconds>] <command> [args...]"
		echo "  -t, --timeout  Timeout in seconds (default: 300 = 5 minutes)"
		exit 0
		;;
	*)
		break
		;;
	esac
done

if [[ $# -eq 0 ]]; then
	echo "Error: No command provided" >&2
	echo "Usage: notify-when [-t <seconds>] <command> [args...]" >&2
	exit 1
fi

CMD="$*"

# Notification function
notify() {
	local title="$1"
	local message="$2"

	if [[ "$OSTYPE" == "darwin"* ]]; then
		osascript -e "display notification \"$message\" with title \"$title\""
	else
		notify-send "$title" "$message"
	fi
}

# Run command in background
"$@" &
PID=$!

# Cleanup function
cleanup() {
	kill -9 "$WAIT_PID" 2>/dev/null || true
}

# Wait for either the command to complete OR timeout
WAITED=0
INTERVAL=5

while [[ $WAITED -lt $TIMEOUT ]]; do
	if ! kill -0 $PID 2>/dev/null; then
		# Command finished
		wait $PID
		EXIT_CODE=$?

		if [[ $EXIT_CODE -eq 0 ]]; then
			notify "✅ Done" "$CMD"
		fi
		exit $EXIT_CODE
	fi

	sleep $INTERVAL
	WAITED=$((WAITED + INTERVAL))
done

# Timeout reached
if kill -0 $PID 2>/dev/null; then
	kill $PID 2>/dev/null || true
	notify "⏰ Timed out" "$CMD ($TIMEOUT seconds)"
	exit 124 # Standard timeout exit code
fi
