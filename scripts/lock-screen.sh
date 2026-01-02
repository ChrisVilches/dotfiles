#!/bin/bash

COLOR="110100"

ensure-lock() {
  if pgrep -x "i3lock" >/dev/null; then
    echo "i3lock is running"
  else
    i3lock --color "$COLOR"
  fi
}

suspend() {
  systemctl suspend
}

ensure-lock &

if [[ "$1" == "suspend" ]]; then
  suspend
fi
