#!/bin/bash

# Keeps the OS from idling/hibernating by nudging the mouse one pixel back and
# forth with xdotool every few seconds. Runs until CTRL+C.
#
# Everything (xdotool, sleep) runs in the foreground, so CTRL+C delivers SIGINT
# to the whole foreground process group and nothing is left behind.

INTERVAL=2

if ! command -v xdotool >/dev/null 2>&1; then
  echo "Error: xdotool is not installed or not in PATH." >&2
  exit 1
fi

trap 'echo; exit 0' INT TERM

cat <<'EOF'
      ( (
       ) )
    ........
    |      |]
    \      /
     `----'
EOF
echo "Nudging the mouse via xdotool every ${INTERVAL}s. CTRL+C to stop."
echo

SECONDS=0
dx=-1

while true; do
  xdotool mousemove_relative -- "$dx" 0
  dx=$((-dx))

  secs=$SECONDS
  printf '\r☕ Caffeine %02d:%02d:%02d' $((secs / 3600)) $(((secs % 3600) / 60)) $((secs % 60))

  sleep "$INTERVAL"
done
